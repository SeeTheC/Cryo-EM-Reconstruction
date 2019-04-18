
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
dataNum = 8647;
maxNumProj=20000;
downspample=1;
extractionType=0;

%% INIT
suffix='';
timestamp=datestr(now,'dd-mm-yyyy-HH_MM_SS');
emBasepath=strcat(basepath,'/',num2str(dataNum),suffix);

%{
datasetPath=strcat(emBasepath,'/Projection_',num2str(dataNum));
datasetImgDir=strcat(datasetPath,'/img');
datasetRawImgDir=strcat(datasetPath,'/raw_img');
%}

datasetPath=strcat(emBasepath,'/Projection_',num2str(dataNum),'_Td2_GaussainNoise_percent_10'); 
datasetImgDir=strcat(datasetPath,'/img');
datasetRawImgDir=strcat(datasetPath,'/raw_img');

clusterDirPath=strcat(datasetPath,'/clustering');mkdir(clusterDirPath);
if extractionType==0
 clusterDirPath=strcat(clusterDirPath,'/vector');mkdir(clusterDirPath);
elseif extractionType==1
 clusterDirPath=strcat(clusterDirPath,'/auto-encoder');mkdir(clusterDirPath);
end

clusterDirPath=strcat(clusterDirPath,'/',timestamp);


mkdir(clusterDirPath);
tmpDir=strcat(datasetPath,'/temp');
tmpProjPath=strcat(tmpDir,'/projections.mat');

mkdir(tmpDir);

%mkdir(savedImgDir);
%mkdir(savedRawImgDir);
%% Info file
infoFile=strcat(clusterDirPath,'/0_info.txt');
infoFileHand=fopen(infoFile,'w+');
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

%%  Extract Feature 

if extractionType==0

    config.extractionType=0; % simple vector
    config.timestamp=timestamp;
    config.downsample=2;
    featureDataPath=strcat(clusterDirPath,'/featureDataset.mat');
    
elseif extractionType==1
    
    config.extractionType=1; % Auto encoder
    config.layerNeuron = 1000;
    config.timestamp=timestamp;
    featureDataPath=strcat(clusterDirPath,'/featureDataset_',num2str(config.layerNeuron),'.mat');
end
%% Extract Feature 

if exist(featureDataPath, 'file') == 2
    fprintf('Fast load: Loading Feature Dataset  from temporary storage...\n'); 
    s=load(featureDataPath,'featureDataset');
    featureDataset=s.featureDataset;
    fprintf('Done.\n');
else
    fprintf('Extracting Features from Projections...\n');     
    [featureDataset] = extractFeature(projections,config);
    save(featureDataPath,'featureDataset','-v7.3');
    fprintf('Done.\n');
end
%% load 
%{
fr=load(saveFDPath);
featureDataset=fr.featureDataset;
fprintf('Done.\n');
%}

%% clustering
k=2500;
clusterType='som';
clustConfig.k=k;
clustConfig.clusterType=clusterType;
clustConfig.maxIter=1000;
clustConfig.replicates=100;
clustConfig.config=config;
clusterTimestamp=datestr(now,'dd-mm-yyyy-HH_MM_SS');
fprintf(infoFileHand,'K-Means K:%d \n',k);
fprintf(infoFileHand,'K-Means maxIter:%d \n',clustConfig.maxIter);
fprintf(infoFileHand,'K-Means replicates:%d \n',clustConfig.replicates);
%%
%fdsGpu=gpuArray(featureDataset);
%[clusterIdx,centroid] = KMeansClustering(featureDataset,clustConfig);
[clusterIdx,centroid,net] = SOM(featureDataset,clustConfig);
saveClusterFP=strcat(clusterDirPath,'/cluster_k',num2str(k),'.mat');
save(saveClusterFP,'clusterIdx');
save(strcat(clusterDirPath,'/clustConfig.mat'),'clustConfig');
save(strcat(clusterDirPath,'/net.mat'),'net');

%% Plotting graph
fprintf('Finding silhouette...\n');
tic
figure
[silh,h] = silhouette(featureDataset,clusterIdx,'cosine');

cluster = mean(silh)
silhStruct.silh=silh;
silhStruct.h=h;
saveClusterSilhFP=strcat(clusterDirPath,'/clusteSilhouetter_k',num2str(k),'.mat');
save(saveClusterSilhFP,'silhStruct');
fprintf(infoFileHand,'silhouette factor:%d \n',cluster);
fprintf('Done\n');

% Plot
%{
h = gca;
h.Children.EdgeColor = [.8 .8 1];
xlabel 'Silhouette Value'
ylabel 'Cluster'
%}
%%
fclose(infoFileHand);
%% Cluster the Images

