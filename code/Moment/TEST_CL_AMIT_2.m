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
dataNum = 4138;
datasetName=num2str(dataNum);
 datasetPath='~/git/Dataset/EM';
 if(dataNum==1003)
    emFile=strcat(datasetPath,'/EMD-1003','/map','/emd_1003.map'); 
    em = mapReader(emFile);
 end
 if(dataNum==4138)
    % Dataset:4138 Dim:161x161x161
    % Percentage of correct common lines: 54.669379%
    emFile=strcat(datasetPath,'/EMD-4138','/map','/EMD-4138.map'); 
    em = mapReader(emFile);
    [em] = imcrop3D(em,80);
 end
 if(dataNum==2451) 
    % Dim:220x220x220
    % Percentage of correct common lines: 72.144166%
    emFile=strcat(datasetPath,'/EMD-2451','/map','/EMD-2451.map');
    em = mapReader(emFile);
 end
 if(dataNum==5578)
    % 400x400x400
    % Percentage of correct common lines: 3.617151%
    emFile=strcat(datasetPath,'/EMD-5578','/map','/EMD-5578.map');
    em = mapReader(emFile);
 end
 if(dataNum==5693) 
    % Percentage of correct common lines: 84.961335
    emFile=strcat(datasetPath,'/EMD-5693','/map','/EMD-5693.map');
    em = mapReader(emFile);
 end
 if(dataNum==5689) 
    % 192x192x192
    % Percentage of correct common lines: 23.460053
    emFile=strcat(datasetPath,'/EMD-5689','/map','/EMD-5689.map');
    em = mapReader(emFile);
 end
 if(dataNum==5762) 
    % Percentage of correct common lines: 32.103770%
    emFile=strcat(datasetPath,'/EMD-5762','/map','/EMD-5762.map');
    em = mapReader(emFile);
 end 
 if(dataNum==2222) 
    % 128x128x128
    emFile=strcat(datasetPath,'/EMD-2222','/map','/EMD-2222.map');
    em = mapReader(emFile);
 end 
 if(dataNum==1050) 
     %Percentage of correct common lines: 28.974619%
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
 if(dataNum==1235) 
     % 56x56x56
     % Percentage of correct common lines: 9.013398%
    emFile=strcat(datasetPath,'/EMD-1235','/map','/EMD-1235.map');
    em = mapReader(emFile);
 end
 if(dataNum==2111) 
     % 54x54x54
    emFile=strcat(datasetPath,'/EMD-2111','/map','/EMD-2111.map');
    em = mapReader(emFile);
 end
 if(dataNum==4006) 
     % 40x40x40
     %  Percentage of correct common lines: 5.518361%
    emFile=strcat(datasetPath,'/EMD-4006','/map','/EMD-4006.map');
    em = mapReader(emFile);
 end


 em(em<0)=0;
 emDim=size(em)'; 
 fprintf('Dataset:%d Dim:%dx%dx%d\n',dataNum,emDim(1),emDim(2),emDim(3));
 em=single(em);
%% crop
[em] = imcrop3D(em,40);
 %% Down
 em=imresize3(em,1/2);
%% Take Projection
% Projection Angles 2: Guassian Distribution & quternion
noOfAngles=100;
quternion=randn(noOfAngles,4);
quternion=quternion./sqrt(sum(quternion.^2,2));
for i=1:noOfAngles
    rotMtx=quat2rotm(quternion(i,:));
    trueRotMat(:,:,i)=rotMtx;
end
%invTrueRotMat=permute(trueRotMat,[2 1 3]);
maxNumProj=noOfAngles;
%% Take Projections

[projections] = takeProjectionWraper(em,trueRotMat);
fprintf('Done\n');
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

rotsAligned = align_rots(predR,trueRotMat); % ASPIRE

%[gobalRotMat] = getGlobalRotTransformation(trueRotMat,predR);
%[rotsAligned,angles] = transformRot(gobalRotMat,predR);

%% Reconstruct

[reconstObjFBP] = reconstructObjWarper(projections,rotsAligned);
figure, imshow3D(reconstObjFBP)

%%
[trueObjFBP] = reconstructObjWarper(projections,trueRotMat);

