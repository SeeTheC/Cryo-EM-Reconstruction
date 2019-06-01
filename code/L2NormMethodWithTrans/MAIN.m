%% 3D Reconstrution of using L2 Norm

%  (G,R_est)  = agmin  || Pi - Radon(G,R_est_i) || for all i=1...N
%   where Pi = ith Projection
%         R_est_i =  R_est of ith Projection
%   
% Author: Khursheed Ali
%% INIT : Library

clear all;
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
addpath(genpath('../../lib/BM3D'));


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


%parentPath=strcat(emBasepath,'/Projection_',num2str(dataNum),'_Crp86_GaussainNoise_percent_50');
parentPath=strcat(emBasepath,'/Projection_',num2str(dataNum),'_Td2'); 
parentImgDir=strcat(parentPath,'/img'); 
parentRawImgDir=strcat(parentPath,'/raw_img');

% translation Dataset Path
parentTransPath=strcat(emBasepath,'/Projection_',num2str(dataNum),'_Td2_trans_error5');
parentTransRawImgDir=strcat(parentTransPath,'/raw_img');


savepath=strcat(parentTransPath,'/Result_Translation'); 
finalSavePath=strcat(savepath,'/proj',num2str(maxNumProj),'_',timestamp);
    
mkdir(savepath);
mkdir(finalSavePath);
    
fprintf('Done\n');
%%
datasetName=num2str(dataNum);
 datasetPath='~/git/Dataset/EM';
 if(dataNum==1003)
    emFile=strcat(datasetPath,'/EMD-1003','/map','/emd_1003.map'); 
    em = mapReader(emFile);
 end
 if(dataNum==5693) 
     % 96x96x96
    emFile=strcat(datasetPath,'/EMD-5693','/map','/EMD-5693.map');
    em = mapReader(emFile);
    %em=imresize3(em,1/2);
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
    em=imresize3(em,1/2);
    [em] = imcrop3D(em,36);
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

%% Croping object
% [em] = imcrop3D(em,20);
%% down
 % em=imresize3(em,1/2);
%% Read Projections

% Assuming Projections are take from ASPIRE;
% fprintf('NOTE: Assuming Projections are take from ASPIRE.\n');

projections=loadProjections(parentRawImgDir,maxNumProj,downspample);
rots_true=load(strcat(parentPath,'/rots_true.mat'));
rots_true=rots_true.rots_true;
rots_true=rots_true(:,:,1:size(projections,3));

% loading Translation Error Projection
trans_projections=loadProjections(parentTransRawImgDir,maxNumProj,downspample);
trans_error_true=load(strcat(parentTransPath,'/trans_error.mat'));
trans_error_true=trans_error_true.trans_error;
trans_error_true=trans_error_true(1:size(trans_projections,3),:);

angles_true=[];
if rmvNoise && noiseRmvMethod==1
    fprintf('Reducing Noise using wiener filter...\n');
    [projections]=rmvNoiseWithWiener(projections);
    saveProjections(projections,parentPath,20,'Wiener');
    fprintf('Done\n');

elseif rmvNoise && noiseRmvMethod==2
    fprintf('Reducing Noise using BM3D filter...\n');
    [projections]=rmvNoiseWithBM3D(projections);
    saveProjections(projections,parentPath,20,'BM3D');
    fprintf('Done\n');
end
%angles_true=load(strcat(parentPath,'/angles.mat'));
%angles_true=angles_true.angles;
%angles_true=angles_true(:,1:size(projections,3));
%% Setting config parameter 

fprintf('Setting config parameter..\n');
config.dataNum=dataNum;
config.maxNumProj=maxNumProj;
config.downspample=downspample;
config.parentPath=parentPath;
config.maxIteration=10;
config.searchOffest=10; % In degree example: +/- 10 deg 
config.savepath=savepath;
config.projections=projections;
config.rots_true=rots_true; % For finding Final error in Reconstruction
config.angles_true=angles_true; % For finding Final error in Reconstruction
config.trans_projections=trans_projections; % used in Optimation method
config.trans_error_true=trans_error_true;
config.transSearchOffset=2; % Its +/- 5 pixel in both x and y
config.timestamp=timestamp;
config.isGpu=true;
config.checkpointing=true; % Used of repeatitive computation on same dataset 
config.checkpointpath=strcat(parentPath,'/temp');
config.trueObj=em;
config.finalSavePath=finalSavePath;
fprintf('Done\n');

%% Test ERROR
% Result:
% N=100 L2error:  0.3824
% N=200 L2error:  0.3684
% N=1000 L2error: 0.3578

%{
[G_init] = reconstructObjWarper(single(projections),rots_true);
p_est=takeProjectionWraper(G_init,rots_true);
%figure,imshow3D(G_init);
error=findL2Error(projections,p_est)
[corrError] = findCorrelationError(projections,p_est)
%}
%% Reconstruct
gpuDevice(1);
[G_final,f_final,R_est,corr_error,G_init,f_init,R_init,cl_error,iteration] = solve3dObj(config);

initL2Error=findL2Error(em,f_init);
initCorr=corr3(em,f_init);
finalL2Error=findL2Error(em,f_final);
finalCorr=corr3(em,f_final);

fprintf('Projection corr_error:%f\n',corr_error);
fprintf('Projection cl_error:%f\n',cl_error);
fprintf('3D obj Intial Estimate L2 Error:%f\n',initL2Error);
fprintf('3D obj Intial Estimate Correaltion:%f\n',initCorr);
fprintf('3D obj Final Estimate L2 Error:%f\n',finalL2Error);
fprintf('3D obj Final Estimate Correaltion:%f\n',finalCorr);


% Saving Results

infoFH=fopen(strcat(config.finalSavePath,'/0_info.txt'),'a+'); 
fprintf(infoFH,'\n----------------[Final Result]---------------------]');
fprintf(infoFH,'iteration:%f\n',iteration);
fprintf(infoFH,'Projection corr_error:%f\n',corr_error);
fprintf(infoFH,'Projection cl_error:%f\n',cl_error);
fprintf(infoFH,'3D obj Intial Estimate L2 Error:%f\n',initL2Error);
fprintf(infoFH,'3D obj Intial Estimate Correaltion:%f\n',initCorr);
fprintf(infoFH,'3D obj Final Estimate L2 Error:%f\n',finalL2Error);
fprintf(infoFH,'3D obj Final Estimate Correaltion:%f\n',finalCorr);
fclose(infoFH);


%finalSaveBP=strcat('../Result/L2Norm'); 
%finalSavePath=strcat(savepath,'/',timestamp);
mkdir(finalSavePath);
result=struct;
result.G_final=G_final;
result.f_final=f_final;
result.R_est=R_est;
result.corr_error=corr_error;
result.G_init=G_init;
result.f_init=f_init;
result.R_init=R_init;
result.cl_error=cl_error;
result.iteration=iteration;
result.initL2Error=initL2Error;
result.initCorr=initCorr;
result.finalL2Error=finalL2Error;
result.finalCorr=finalCorr;
result.config=config;

save(strcat(finalSavePath,'/final_result.mat'),'result');


