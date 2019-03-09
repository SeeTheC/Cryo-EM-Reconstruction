% Test AMIT common-line LIBRARY
%% INIT
clear all;
addpath(genpath('../../lib/aspire-v0.14-0'));
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
addpath(genpath('../FileOperation'));
addpath(genpath('../CommonFunctions'));
addpath(genpath('CommonLine/'));
callPath=pwd;
cd('../../lib/CERN-TIGRE/MATLAB'); 
funInitTIGRE();
cd(callPath); 
server = 1
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Reconstruction/code/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end

%% Config
dataNum = 100;
datasetName=num2str(dataNum);
 datasetPath='~/git/Dataset/EM';
 if(dataNum==1003)
    emFile=strcat(datasetPath,'/EMD-1003','/map','/emd_1003.map'); 
    em = mapReader(emFile);
 end
 if(dataNum==5693) 
    emFile=strcat(datasetPath,'/EMD-5693','/map','/EMD-5693.map');
    em = mapReader(emFile);
 end
 if(dataNum==5689) 
    emFile=strcat(datasetPath,'/EMD-5689','/map','/EMD-5689.map');
    em = mapReader(emFile);
 end
 if(dataNum==5762) 
    emFile=strcat(datasetPath,'/EMD-5762','/map','/EMD-5762.map');
    em = mapReader(emFile);
 end 
 if(dataNum==2222) 
    emFile=strcat(datasetPath,'/EMD-2222','/map','/EMD-2222.map');
    em = mapReader(emFile);
 end 
 if(dataNum==1050) 
    emFile=strcat(datasetPath,'/EMD-1050','/map','/EMD-1050.map');
    em = mapReader(emFile);
 end 
 em(em<0)=0;
 emDim=size(em)'; 
 fprintf('Dataset:%d Dim:%dx%dx%d\n',dataNum,emDim(1),emDim(2),emDim(3));
 
%% Set Paths
datasetName=num2str(dataNum);
%datasetName=strcat(datasetName,'_90degRot');

parentDirPath=strcat(basepath,'/',datasetName);

%subDirPath=strcat(parentDirPath,'/Projection_',num2str(dataNum),'_rnd');
subDirPath=strcat(parentDirPath,'/Projection_',num2str(dataNum),'_guassina_dis_Quat');
%subDirPath=strcat(parentDirPath,'/Projection_',num2str(dataNum),'_manual');


tmpsaveDir=strcat('TmpSave/',datasetName);


rawProjPath=strcat(subDirPath,'/raw_img');
maxNumProj=500;
mkdir(tmpsaveDir);
suffix='_guassina_dis_Quat_2000';
%suffix='_c_500';
%suffix='_90deg_manual';

tmpProjPath=strcat(tmpsaveDir,'/tmp_result/projections',suffix,'.mat');
tmpProj1DPath=strcat(tmpsaveDir,'/tmp_result/proj1D',suffix,'.mat');
tmpProjFourierLinesPath=strcat(tmpsaveDir,'/tmp_result/projLineFourierDomain_angRes_1',suffix,'.mat');
tmpPhiPath=strcat(tmpsaveDir,'/tmp_result/phi',suffix,'.mat');
tmpPhiFourierLinePath=strcat(tmpsaveDir,'/tmp_result/phiFourierLine_angRes_1',suffix,'.mat');
tmpTruePhiPath=strcat(tmpsaveDir,'/tmp_result/truePhi',suffix,'.mat');
tmpTrueSPath=strcat(tmpsaveDir,'/tmp_result/trueS',suffix,'.mat');

%% Load Projections
if exist(tmpProjPath, 'file') == 2
    fprintf('Fast load: Loading it from temporary storage...\n'); 
    projections=load(tmpProjPath,'projections');
    projections=projections.projections;
    projections=projections(:,:,1:maxNumProj);
    fprintf('Done.\n');
else
    fprintf('Loading it from file...\n');     
    projections=loadProjections(rawProjPath,maxNumProj,1);
    save(tmpProjPath,'projections','-v7.3');
    fprintf('Done.\n');
end
trueAngles=load(strcat(subDirPath,'/angles.mat'),'angles');
trueAngles=trueAngles.angles;
trueAngles=trueAngles(:,1:min(maxNumProj,size(trueAngles,2)));
[trueRotMat] = convertAngleToRotMat(trueAngles');

%% Load/Find 1D Projections
clear proj1D;
if exist(tmpProj1DPath, 'file') == 1
    fprintf('Fast load: Loading 1D Projections from temporary storage...\n'); 
    proj1D=load(tmpProj1DPath,'proj1D');
    proj1D=proj1D.proj1D;
    fprintf('Done.\n');    
else
    fprintf('Calculating 1D projection ...\n'); 
    [proj1D] = get1DProjections(projections);
    %save(tmpProj1DPath,'proj1D','-v7.3');
    fprintf('Calculation Done.\n');
end


%% Load/Find phi using Fourier Lines

if exist(tmpPhiFourierLinePath, 'file') == 2
    fprintf('Fast load: Loading phi (using Fourier Lines) from temporary storage...\n'); 
    phiFourierLineStruct=load(tmpPhiFourierLinePath);
    phiFourierLineStruct=phiFourierLineStruct.phiFourierLineStruct;
    phiFourierLine=phiFourierLineStruct.phi;
    angResolution=phiFourierLineStruct.angResolution;
    fprintf('Done.\n');
else
    fprintf('Calculating phi (using Fourier Lines)...\n');   
    gfourierLines=gpuArray(fourierLines);
    %gfourierLines=fourierLines;
    [phiFourierLine,errorFourierLine] = getPhiUsingFourierLines(gfourierLines,angResolution);
    phiFourierLineStruct.phi=phiFourierLine;
    phiFourierLineStruct.angResolution=angResolution;    
    clear gfourierLines;
    save(tmpPhiFourierLinePath,'phiFourierLineStruct','-v7.3');
    fprintf('Done.\n');
end
%% Load/Find phi using 1d Projection

if exist(tmpPhiPath, 'file') == 2
    fprintf('Fast load: Loading phi from temporary storage...\n'); 
    phi=load(tmpPhiPath,'phi');
    phi=phi.phi;
    fprintf('Done.\n');
else
    fprintf('Calculating phi...\n');   
    gproj1D=gpuArray(proj1D);
    %gproj1D=proj1D;
    [phi,error] = getPhi(gproj1D);
    clear gproj1D;
    %save(tmpPhiPath,'phi','-v7.3');
    fprintf('Done.\n');
end
%% Calculate True S and Phi

if exist(tmpTruePhiPath, 'file') == 1
    fprintf('Fast load: Loading phi from temporary storage...\n'); 
    truePhi=load(tmpTruePhiPath,'truePhi');
    truePhi=truePhi.truePhi;
    truePhiDeg=truePhi.*(180/pi);
    fprintf('Done.\n');
else
    fprintf('Calculating truePhi ...\n');       
    [trueS,truePhi] = ASINGER2011_GetS_TESTFun(trueRotMat); 
    truePhiDeg=truePhi.*(180/pi);
    %save(tmpTruePhiPath,'truePhi','-v7.3');
    %save(tmpTrueSPath,'trueS','-v7.3');
    fprintf('Done.\n');
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ---------------------------------------------------------

fprintf('Finding S:\n');
radian=pi/180;
%S=ASINGER2011_GetS_step1(phiFourierLine);
%S=ASINGER2011_GetS_step1(truePhiWithError);
%S=ASINGER2011_GetS_step1(truePhi);
S=ASINGER2011_GetS_step1(phi.*radian);
%S=trueS;
fprintf('Done.\n');
%%
fprintf('Finding rotation matrix\n');
[predR,ZYZ,U,Sv,V] = ASINGER2011_GetR_step2(S,size(truePhi,1));
fprintf('Done.\n');
%% Fing Global Rotation
fprintf('Finding Global tranformation matrix\n');
[trueRotMat] = convertAngleToRotMat(trueAngles');
[gobalRotMat] = getGlobalRotTransformation(trueRotMat,predR);
[newPredR,newZYZ] = transformRot(gobalRotMat,predR);
fprintf('Done.\n');


%% Reconstruct image using OS-SART and FDK
emDim=[160,160,160]';
noOfProj=size(newZYZ,2);
p=single(projections);
[reconstObjFBP] = reconstructObj(p,newZYZ,emDim);
[trueObjFBP]=reconstructObj(p(:,:,1:noOfProj),trueAngles(:,1:noOfProj),emDim);
imshow3D(reconstObjFBP);
%%
%% AAAAAAAAA
trueRotMat=rots;
predR=est_inv_rots;
trueAngles=rotm2eul(trueRotMat,'ZYZ')';

[gobalRotMat] = getGlobalRotTransformation(trueRotMat,predR);
[newPredR,newZYZ] = transformRot(gobalRotMat,predR);
%% AAAAAAAAAA: REc

emDim=[160,160,160]';
noOfProj=size(newZYZ,2);
p=single(projections);
[reconstObjFBP] = reconstructObj(p,newZYZ,emDim);
[trueObjFBP]=reconstructObj(p(:,:,1:noOfProj),trueAngles(:,1:noOfProj),emDim);
imshow3D(reconstObjFBP);


