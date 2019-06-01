%% Add Translation Error to projection
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
dataNum = 8647;
maxNumProj=1005;
downspample=1;
maxTransError=5;% in pixels

timestamp=datestr(now,'dd-mm-yyyy-HH_MM_SS');
emBasepath=strcat(basepath,'/',num2str(dataNum));

suffix='_Td2';
parentPath=strcat(emBasepath,'/Projection_',num2str(dataNum),suffix);
parentImgDir=strcat(parentPath,'/img');
parentRawImgDir=strcat(parentPath,'/raw_img');

savepath=strcat(emBasepath,'/Projection_',num2str(dataNum),suffix,'_trans_error',num2str(maxTransError),'_',timestamp); 
savedImgDir=strcat(savepath,'/img');
savedRawImgDir=strcat(savepath,'/raw_img');


mkdir(savepath);
mkdir(savedImgDir);
mkdir(savedRawImgDir);

%% Read All Files

projections=loadProjections(parentRawImgDir,maxNumProj,downspample);


%% Add noise and Save
N=size(projections,3);
fprintf('Adding Translation error ...\n');
trans_error=[];
for i=1:N
    p=projections(:,:,i);        
    [m,n]=size(p);    
    xError=randi([(-1*maxTransError) maxTransError]);
    yError=randi([(-1*maxTransError) maxTransError]);
    fprintf('i:%d\t xerror:%d\t yerror:%d\n',i,xError,yError);
    img=imtranslate(p,[xError,yError]);
    trans_error=[trans_error;xError,yError];
    % saving raw img
    save(strcat(savedRawImgDir,'/',num2str(i),'.mat'),'img');    
    maxValue=max(img(:)); 
    minValue=min(img(:)); 
    img=img-minValue;
    %Saving img
    imwrite(img./maxValue,strcat(savedImgDir,'/',num2str(i),'.jpg'));
    % writing to file
    
end
save(strcat(savepath,'/trans_error.mat'),'trans_error');
fprintf('Done.\n');
