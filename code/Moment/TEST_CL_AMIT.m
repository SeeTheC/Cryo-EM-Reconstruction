% Test AMIT common-line LIBRARY
%% INIT
clear all;
addpath(genpath('../../lib/aspire-v0.14-0'));
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
addpath(genpath('../FileOperation'));
addpath(genpath('../CommonFunctions'));
addpath(genpath('../CommonLine/'));
callPath=pwd;
cd('../../lib/CERN-TIGRE/MATLAB'); 
funInitTIGRE();
cd(callPath); 
server = 1;
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Reconstruction/code/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end


%% Config
dataNum = 8647;
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

 if(dataNum==76) 
    emFile=strcat(datasetPath,'/EMD-0076','/map','/EMD-0076.map');
    em = mapReader(emFile);
 end
 if(dataNum==8647) 
     % 128x128x128
    emFile=strcat(datasetPath,'/EMD-8647','/map','/EMD-8647.map');
    em = mapReader(emFile);
 end
 if(dataNum==70)
    % 65x65x65
    root = aspire_root();
    file_name = fullfile(root, 'projections', 'simulation', 'maps', 'cleanrib.mat');
    em = load(file_name);
    em=em.volref;
    em=single(em);
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
maxNumProj=100;
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

%% Take Projection
% Projection Angles 2: Guassian Distribution & quternion
noOfAngles=100;
quternion=randn(noOfAngles,4);
quternion=quternion./sqrt(sum(quternion.^2,2));
for i=1:noOfAngles
    [a,b,c]=quat2angle(quternion(i,:),'ZYZ');
    angles(:,i)=[a,b,c]';
end

trueAngles=angles;
[trueRotMat] = convertAngleToRotMat(trueAngles');

maxNumProj=noOfAngles;
%%
% VARIABLE                                   DESCRIPTION                    UNITS
%-------------------------------------------------------------------------------------
%geo.DSD = 1536;                             % Distance Source Detector     (mm)
geo.DSD = 1000;                             % Distance Source Detector      (mm)
geo.DSO = 500;                             % Distance Source Origin        (mm)
% Detector parameters
geo.nDetector=[150; 150];					% number of pixels              (px)
geo.dDetector=[1; 1]; 					% size of each pixel            (mm)
geo.sDetector=geo.nDetector.*geo.dDetector; % total size of the detector    (mm)
% Image parameters
geo.nVoxel=emDim;                           % number of voxels              (vx)
geo.sVoxel=emDim;                           % total size of the image       (mm)
geo.dVoxel=geo.sVoxel./geo.nVoxel;          % size of each voxel            (mm)
% Offsets
geo.offOrigin =[0;0;0];                     % Offset of image from origin   (mm)              
geo.offDetector=[0; 0];                     % Offset of Detector            (mm)

% Auxiliary 
geo.accuracy=0.5;                           % Accuracy of FWD proj          (vx/sample)

% Projection Type : parallel/cone
geo.mode='parallel';

fprintf('Taking projection...\n');
tic
projections=Ax(em,geo,angles,'interpolated');
toc
fprintf('Done\n');
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

%% Load/Find Lines from Fourier Domain

if exist(tmpProjFourierLinesPath, 'file') == 1
    fprintf('Fast load: Loading Fourier lines Projections from temporary storage...\n'); 
    fourierProjStruct=load(tmpProjFourierLinesPath);
    fourierProjStruct=fourierProjStruct.fourierProjStruct;
    fourierLines=fourierProjStruct.fourierLines;
    angResolution=fourierProjStruct.angResolution;    
    fprintf('Done.\n');    
else
    angResolution=1;
    fprintf('Calculating Fourier lines projection ...\n'); 
    [fourierLines] = getAllFourierDomainCL(projections,angResolution);
    fourierProjStruct.fourierLines=fourierLines;
    fourierProjStruct.angResolution=angResolution;
    %save(tmpProjFourierLinesPath,'fourierProjStruct','-v7.3');
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
    gfourierLines=fourierLines;    
    gfourierLines=gpuArray(fourierLines);
    [phiFourierLine,errorFourierLine] = getPhiUsingFourierLines(gfourierLines,angResolution);
    phiFourierLineStruct.phi=phiFourierLine;
    phiFourierLineStruct.angResolution=angResolution;    
    clear gfourierLines;
    save(tmpPhiFourierLinePath,'phiFourierLineStruct','-v7.3');
    fprintf('Done.\n');
end
%% Load/Find phi using 1d Projection

if exist(tmpPhiPath, 'file') == 1
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
    truePhiDeg=round((truePhi+pi).*(180/pi));
    truePhiDeg(1:1+size(truePhiDeg,1):end) = 0;
    fprintf('Done.\n');
else
    fprintf('Calculating truePhi ...\n');       
    [trueS,truePhi] = ASINGER2011_GetS_TESTFun(trueRotMat); 
    truePhiDeg=round((truePhi+pi).*(180/pi));
    truePhiDeg(1:1+size(truePhiDeg,1):end) = 0;
    %save(tmpTruePhiPath,'truePhi','-v7.3');
    %save(tmpTrueSPath,'trueS','-v7.3');
    fprintf('Done.\n');
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ---------------------------------------------------------

fprintf('Finding S:\n');
radian=pi/180;
%S=ASINGER2011_GetS_step1(phiFourierLine*radian);
%S=ASINGER2011_GetS_step1(truePhiWithError);
%S=ASINGER2011_GetS_step1(truePhi);
S=ASINGER2011_GetS_step1(phi.*radian);
%S=trueS;
fprintf('Done.\n');
%%
fprintf('Finding rotation matrix\n');
[predR,ZYZ,U,Sv,V] = ASINGER2011_GetR_step2(S,size(phi,1));
fprintf('Done.\n');
%% Verify PredR
radian=pi/180;
R1=predR(:,:,1);
R2=predR(:,:,2);
R1*[cos(phi(1,2)*radian);sin(phi(1,2)*radian);0]
R2*[cos(phi(2,1)*radian);sin(phi(2,1)*radian);0]

%% Fing Global Rotation
fprintf('Finding Global tranformation matrix\n');
[trueRotMat] = convertAngleToRotMat(trueAngles');
[gobalRotMat] = getGlobalRotTransformation(trueRotMat,predR);
[newPredR,newZYZ] = transformRot(gobalRotMat,predR);

myRotMtx = align_rots(predR, trueRotMat);
myZYZAmitAligned=rotm2eul(myRotMtx,'ZYZ')';


fprintf('Done.\n');

%% 
 inv_rots_aligned = align_rots(invert_rots(predR), invert_rots(trueRotMat));
 newZYZ=rotm2eul(inv_rots_aligned,'ZYZ')';
 
 trueZYZ=rotm2eul(invert_rots(trueRotMat),'ZYZ')';
 shifts=zeros(100,2);
 
%% Reconstruct image using OS-SART and FDK
emDim=[360,360,360]';
noOfProj=size(newZYZ,2);
p=single(projections);
[reconstObjFBP] = reconstructObj(p,myZYZAmitAligned,emDim);
angles=trueAngles;
angles(2,:)=trueAngles(2,:);
[trueObjFBP]=reconstructObj(p(:,:,1:noOfProj),angles(:,1:noOfProj),emDim);
imshow3D(reconstObjFBP);
%imshow3D(trueObjFBP);
%% 
myRotMtx = align_rots(predR,inv_rots_true);
myZYZAmitAligned=rotm2eul(myRotMtx,'ZYZ')';
emDim=[360,360,360]';
[reconstObjFBP] = reconstructObj(p,myZYZAmitAligned,emDim);
imshow3D(reconstObjFBP);

%% AMIT %%%%%%%%%%%%%%%%%%%%%%%%%%%
n_theta=360;
%S_est = cryo_syncmatrix_vote(truePhiDeg, n_theta);
S_est = cryo_syncmatrix_vote(phiFourierLine, n_theta);
inv_rots_est = cryo_syncrotations(S_est);
% save('TmpSave/inv_rots_est.mat','inv_rots_est');
% save('TmpSave/S_est.mat','S_est');
%%
R1=inv_rots_est(:,:,1);
R2=inv_rots_est(:,:,2);
R1*[cos(truePhi(1,2));sin(truePhi(1,2));0]
R2*[cos(truePhi(2,1));sin(truePhi(2,1));0]


%% AAAAAAAAA
%trueRotMat=rots;
%predR=inv_rots_est;

ZYZAmit=rotm2eul(inv_rots_est,'ZYZ')';
[gobalRotMatAMit] = getGlobalRotTransformation(trueRotMat,inv_rots_est);
[newPredRAmit,newZYZAmit] = transformRot(gobalRotMatAMit,inv_rots_est);

inv_rots_aligned = align_rots(inv_rots_est, trueRotMat);
newZYZAmitAligned=rotm2eul(inv_rots_aligned,'ZYZ')';
 
%%
newZYZAmitAligned=rotm2eul(inv_rots_aligned,'ZYZ')';
trueAngles=rotm2eul(inv_rots_true,'ZYZ')';

%% AAAAAAAAAA: REc

emDim=[160,160,160]';
noOfProj=size(newZYZAmitAligned,2);
p=single(projections);
[reconstObjFBP] = reconstructObj(p,newZYZAmitAligned,emDim);
[trueObjFBP]=reconstructObj(p(:,:,1:noOfProj),trueAngles(:,1:noOfProj),emDim);
imshow3D(reconstObjFBP);
% figure,imshow3D(trueObjFBP);
%%


