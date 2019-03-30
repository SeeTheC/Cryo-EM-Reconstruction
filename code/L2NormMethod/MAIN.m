%% 3D Reconstrution of using L2 Norm

%  (G,R_est)  = agmin  || Pi - Radon(G,R_est_i) || for all i=1...N
%   where Pi = ith Projection
%         R_est_i =  R_est of ith Projection
%   

%% INIT : Library
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


%% Config 1: File Path
dataNum = 8647;
maxNumProj=100;
downspample=1;

%% Initiatation of working director 
fprintf('Initiatation of working director..\n');

suffix='';
timestamp=datestr(now,'dd-mm-yyyy-HH_MM_SS');
emBasepath=strcat(basepath,'/',num2str(dataNum),suffix);

parentPath=strcat(emBasepath,'/Projection_',num2str(dataNum));
parentImgDir=strcat(parentPath,'/img');
parentRawImgDir=strcat(parentPath,'/raw_img');

savepath=strcat(parentPath,'/Result'); 

mkdir(savepath);

fprintf('Done\n');

%% Read Projections

% Assuming Projections are take from ASPIRE;
fprintf('NOTE: Assuming Projections are take from ASPIRE.\n');

projections=loadProjections(parentRawImgDir,maxNumProj,downspample);
angles_true=load(strcat(parentPath,'/angles.mat'));
rots_true=load(strcat(parentPath,'/rots_true.mat'));
rots_true=rots_true.rots_true;
angles_true=angles_true.angles;
angles_true=angles_true(:,1:size(projections,3));
rots_true=rots_true(:,:,1:size(projections,3));
%% Setting config parameter 

fprintf('Setting config parameter..\n');
config.dataNum=dataNum;
config.maxNumProj=maxNumProj;
config.downspample=downspample;
config.parentPath=parentPath;
config.savepath=savepath;
config.projections=projections;
config.rots_true=rots_true; % For finding Final error in Reconstruction
config.angles_true=angles_true; % For finding Final error in Reconstruction
config.timestamp=timestamp;
config.isGpu=true;
fprintf('Done\n');
%% Reconstruct

[recontObj] = solve3dObj(config);

%%


