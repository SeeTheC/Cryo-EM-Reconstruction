
%% INIT
clear all;
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
addpath(genpath('../FileOperation'));
addpath(genpath('../CommonFunctions'));
addpath(genpath('FeatureExtraction/'));
addpath(genpath('Clustering/'));
server = 1
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Reconstruction/code/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end

%% Config 1: File Path
dataNum = 1050;
maxNumProj=20000;
downspample=1;

suffix='';
timestamp=datestr(now,'dd-mm-yyyy-HH_MM_SS');
emBasepath=strcat(basepath,'/',num2str(dataNum),suffix);

%{
datasetPath=strcat(emBasepath,'/Projection_',num2str(dataNum));
datasetImgDir=strcat(datasetPath,'/img');
datasetRawImgDir=strcat(datasetPath,'/raw_img');
%}

datasetPath=strcat(emBasepath,'/Projection_',num2str(dataNum),'_GaussainNoise_percent_50'); 
datasetImgDir=strcat(datasetPath,'/img');
datasetRawImgDir=strcat(datasetPath,'/raw_img');

saveClusterDirPath=strcat(datasetPath,'/clustering');

tmpDir=strcat(datasetPath,'/TmpSave');
tmpProjPath=strcat(tmpDir,'/projections.mat');

mkdir(tmpDir);
mkdir(saveClusterDirPath);
%mkdir(savedImgDir);
%mkdir(savedRawImgDir);

%% Read All Files

if exist(tmpProjPath, 'file') == 2
    fprintf('Fast load: Loading it from temporary storage...\n'); 
    projections=load(tmpProjPath,'projections');
    projections=projections.projections;
    fprintf('Done.\n');
else
    fprintf('Loading it from file...\n');     
    projections=loadProjections(datasetRawImgDir,maxNumProj,1);
    save(tmpProjPath,'projections','-v7.3');
    fprintf('Done.\n');
end

%projections=loadProjections(datasetRawImgDir,maxNumProj,downspample);

%%  Extract Feature : Config 0
config.extractionType=0; % simple vector
config.timestamp=timestamp;
config.downsample=2;

%%  Extract Feature : Config 1
config.extractionType=1; % Auto encoder
config.layerNeuron = 1000;
config.timestamp=timestamp;

%% Extract Feature 

[featureDataset] = extractFeature(projections,config);
%% save
fnfr=strcat(saveClusterDirPath,'/featureExtract1_2500.mat');
save(fnfr,'featureDataset');

%% load 
fnfr=strcat(saveClusterDirPath,'/featureExtract1_5000.mat');
fr=load(fnfr);
featureDataset=fr.featureDataset;
fprintf('Done.\n');
%% clustering
k=2000;
clusterType='k-means';
clustConfig.k=k;
clustConfig.clusterType=clusterType;
clustConfig.maxIter=1000;
clustConfig.replicates=100;
clusterTimestamp=datestr(now,'dd-mm-yyyy-HH_MM_SS');

%%
%fdsGpu=gpuArray(featureDataset);
[clusterIdx,centroid] = KMeansClustering(featureDataset,clustConfig);
saveClusterFP=strcat(saveClusterDirPath,'/cluster_featureType',num2str(config.extractionType),'_',clusterType,'_k',num2str(k),'_',clusterTimestamp,'.mat');
save(saveClusterFP,'clusterIdx');

%% Plotting graph
fprintf('Finding silhouette...\n');
tic
figure
[silh,h] = silhouette(featureDataset,clusterIdx,'cosine');

h = gca;
h.Children.EdgeColor = [.8 .8 1];
xlabel 'Silhouette Value'
ylabel 'Cluster'
cluster = mean(silh)
silhStruct.silh=silh;
silhStruct.h=h;
saveClusterSilhFP=strcat(saveClusterDirPath,'/clusteSilhouetter_featureType_cos',num2str(config.extractionType),'_',clusterType,'_k',num2str(k),'_',clusterTimestamp,'.mat');
save(saveClusterSilhFP,'silhStruct');
fprintf('Don\n');
toc

