%% 3D Reconstrution of using Moment Optimazation

% Author: Khursheed Ali
%% INIT : Library

clear all;
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
addpath(genpath('../FileOperation'));
addpath(genpath('../CommonFunctions'));
addpath(genpath('../CommonLine/'));
addpath(genpath('Functions/'));
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
addpath(genpath('../../lib/BM3D'));
%%

%% Config 1: File Path
dataNum = 8647
maxNumProj=100;
downspample=1;
rmvNoise=false;
noiseRmvMethod=2; % 1: Wiener method 2: BM3D method

%% Initiatation of working director 
fprintf('Initiatation of working director..\n');

suffix='';
timestamp=datestr(now,'dd-mm-yyyy-HH_MM_SS');
emBasepath=strcat(basepath,'/',num2str(dataNum),suffix);

%parentPath=strcat(emBasepath,'/Projection_',num2str(dataNum),'_TCrp20_GaussainNoise_percent_10');
parentPath=strcat(emBasepath,'/Projection_',num2str(dataNum),'_Td2');

parentImgDir=strcat(parentPath,'/img');
parentRawImgDir=strcat(parentPath,'/raw_img');

savepath=strcat(parentPath,'/Result_Moment'); 
finalSavePath=strcat(savepath,'/proj',num2str(maxNumProj),'_',timestamp);
    
mkdir(savepath);
mkdir(finalSavePath);
    
fprintf('Done\n');
%% 3d obj
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
    [em] = imcrop3D(em,20);
 end 

 if(dataNum==76) 
    emFile=strcat(datasetPath,'/EMD-0076','/map','/EMD-0076.map');
    em = mapReader(emFile);
 end
 if(dataNum==8647) 
     % 128x128x128
    emFile=strcat(datasetPath,'/EMD-8647','/map','/EMD-8647.map');
    em = mapReader(emFile);
    em=imresize3(em,1/2);
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

%% Read Projections

% Assuming Projections are take from ASPIRE;
% fprintf('NOTE: Assuming Projections are take from ASPIRE.\n');

projections=loadProjections(parentRawImgDir,maxNumProj,downspample);
projections=single(projections);
rots_true=load(strcat(parentPath,'/rots_true.mat'));
rots_true=rots_true.rots_true;
rots_true=rots_true(:,:,1:size(projections,3));
angles_true=[];
if rmvNoise && noiseRmvMethod==1
    fprintf('Reducing Noise using wiener filter...\n');
    [projections]=rmvNoiseWithWiener(projections);
    fprintf('Done\n');

elseif rmvNoise && noiseRmvMethod==2
    fprintf('Reducing Noise using BM3D filter...\n');
    [projections]=rmvNoiseWithBM3D(projections);
    fprintf('Done\n');
end

%% Setting config parameter 

fprintf('Setting config parameter..\n');
config.dataNum=dataNum;
config.maxNumProj=maxNumProj;
config.downspample=downspample;
config.parentPath=parentPath;
config.momentOrder=3;
config.maxIteration=20;
config.searchOffest=1; % In degree example: +/- 10 deg 
config.savepath=savepath;
config.projections=projections;
config.rots_true=rots_true; % For finding Final error in Reconstruction
config.angles_true=angles_true; % For finding Final error in Reconstruction
config.timestamp=timestamp;
config.isGpu=true;
config.checkpointing=true; % Used of repeatitive computation on same dataset 
config.checkpointpath=strcat(parentPath,'/temp');
config.trueObj=em; % used for creating comparision video
config.finalSavePath=finalSavePath;
fprintf('Done\n');

%% Reconstruct
[f_final,R_est,f_init,R_init] = findAngleByCoordinateDecent(config);







