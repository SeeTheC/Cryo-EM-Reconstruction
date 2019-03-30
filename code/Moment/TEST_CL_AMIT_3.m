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
 
%% Take Projection
% Projection Angles 2: Guassian Distribution & quternion
noOfAngles=100;
quternion=randn(noOfAngles,4);
quternion=quternion./sqrt(sum(quternion.^2,2));
for i=1:noOfAngles
    rotMtx=quat2rotm(quternion(i,:));
    trueRotMat(:,:,i)=rotMtx;
end
maxNumProj=noOfAngles;
%% Take Projections
angles=rotm2eul(trueRotMat,'ZYX')';
angles(2,:)=angles(2,:)+pi/2; % Adding correction offset
% Take Projection
[projections] = takeProjections(em,angles);

%% Find Common Line
isGpu=true;
[phi,error] = getCommonline(projections,isGpu);

%% Error Common line
[truePhi,~] = getCommonlineFrmRotMtx(trueRotMat); 
prop=comparecl( truePhi, phi, 360, 1 );
fprintf('Percentage of correct common lines: %f%%\n\n',prop*100);
fprintf('Done.\n');

%% ------------------[AMIT SINGRE LOGIC For finding R]---------------------------------------

fprintf('Finding Rotation Matrix:\n');
radian=pi/180;
S=ASINGER2011_GetS_step1(phi.*radian);
%S=trueS;
[predR] = ASINGER2011_GetR_step2(S,size(phi,1));
fprintf('Done.\n');
%% Verify PredR
radian=pi/180;
R1=predR(:,:,1);
R2=predR(:,:,2);
R1*[cos(phi(1,2)*radian);sin(phi(1,2)*radian);0]
R2*[cos(phi(2,1)*radian);sin(phi(2,1)*radian);0]

%% Finding Global Rotation

% rotsAligned = align_rots(predR,trueRotMat); % ASPIRE

[gobalRotMat] = getGlobalRotTransformation(trueRotMat,predR);
[rotsAligned,angles] = transformRot(gobalRotMat,predR);


%% Reconstruct

angles=rotm2eul(rotsAligned,'ZYX')';
angles(2,:)=angles(2,:)+pi/2; % Adding correction offset
[reconstObjFBP] = reconstructObj(projections,angles,emDim);
figure, imshow3D(reconstObjFBP)

%%

