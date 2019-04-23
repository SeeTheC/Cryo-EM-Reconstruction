%% Add noise to projection
%% INIT - Reading Data Set
clear all;
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
addpath(genpath('../FileOperation'));
addpath(genpath('../CommonFunctions'));
rng(1);
server = 1
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Reconstruction/code/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end
callPath=pwd;
cd('../../lib/CERN-TIGRE/MATLAB'); 
funInitTIGRE();
cd(callPath); 
%% Config 1: File Path
dataNum = 5693;
maxNumProj=20000;
downspample=1;
noisePercent=50;

timestamp=datestr(now,'dd-mm-yyyy-HH_MM_SS');
emBasepath=strcat(basepath,'/',num2str(dataNum));

suffix='_Td2';
parentPath=strcat(emBasepath,'/Projection_',num2str(dataNum),suffix);
parentImgDir=strcat(parentPath,'/img');
parentRawImgDir=strcat(parentPath,'/raw_img');

savepath=strcat(emBasepath,'/Projection_',num2str(dataNum),suffix,'_GaussainNoise_percent_',num2str(noisePercent),'_',timestamp); 
savedImgDir=strcat(savepath,'/img');
savedRawImgDir=strcat(savepath,'/raw_img');


mkdir(savepath);
mkdir(savedImgDir);
mkdir(savedRawImgDir);

%% Read All Files

projections=loadProjections(parentRawImgDir,maxNumProj,downspample);


%% Add noise and Save
N=size(projections,3);
fprintf('Adding Nosie ...\n');
avgInt=projections(projections>0);
avgInt=mean(avgInt);
sigma=avgInt*noisePercent/100;
for i=1:N
    p=projections(:,:,i);        
    [m,n]=size(p);
    noise=guassainNoise(m,n,sigma);
    img=p+noise;
    
    % saving raw img
    save(strcat(savedRawImgDir,'/',num2str(i),'.mat'),'img');    
    maxValue=max(img(:)); 
    minValue=min(img(:)); 
    img=img-minValue;
    %Saving img
    imwrite(img./maxValue,strcat(savedImgDir,'/',num2str(i),'.jpg'));
    % writing to file
    
end
fprintf('Done.\n');
