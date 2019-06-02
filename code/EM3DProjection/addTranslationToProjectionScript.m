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

suffix='_Td2_GaussainNoise_percent_100';
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

%% load translation
translationPath=strcat(emBasepath,'/Projection_',num2str(dataNum),'_Td2_trans_error5/','trans_error.mat');

 if exist(translationPath, 'file') == 2
    fprintf('Loading: Translation Error..\n');
    s=load(translationPath);
    trans_error=s.trans_error;
    fprintf('Done\n');
 else
     trans_error=[];
 end

%% Add Tranlation and Save
N=size(projections,3);
fprintf('Adding Translation error ...\n');
if size(trans_error,1)==0
    transExits=false;
else
    transExits=true;
end
for i=1:N
    p=projections(:,:,i);        
    if transExits
     [xError]= trans_error(i,1);
     [yError]= trans_error(i,2);
    else 
        xError=randi([(-1*maxTransError) maxTransError]);
        yError=randi([(-1*maxTransError) maxTransError]);
        trans_error=[trans_error;xError,yError];
    end
    fprintf('i:%d\t xerror:%d\t yerror:%d\n',i,xError,yError);
    img=imtranslate(p,[xError,yError]);
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
