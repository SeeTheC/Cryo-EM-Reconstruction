% Test common-line
%% INIT
clear all;
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
addpath(genpath('../FileOperation'));
addpath(genpath('CommonLine/'));
callPath=pwd;
cd('../../lib/CERN-TIGRE/MATLAB'); 
funInitTIGRE();
cd(callPath); 
server = 1
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Reconstruction/code/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end
%% Config
dataNum = 5689;
parentDirPath=strcat(basepath,'/',num2str(dataNum));
subDirPath=strcat(parentDirPath,'/Projection_',num2str(dataNum),'_rnd');
rawProjPath=strcat(subDirPath,'/raw_img');
maxNumProj=500;
tmpsaveDir=strcat('TmpSave/',num2str(dataNum));
mkdir(tmpsaveDir);
suffix='_c_500';
tmpProjPath=strcat(tmpsaveDir,'/tmp_result/projections',suffix,'.mat');
tmpProj1DPath=strcat(tmpsaveDir,'/tmp_result/proj1D',suffix,'.mat');
tmpPhiPath=strcat(tmpsaveDir,'/tmp_result/phi',suffix,'.mat');

%%
PP1=[
        1,2,3,4,5;
        6,34,23,56,10;
        14,67,89,13,65;
        43,56,34,78,6;
        12,67,98,45,23;    
    ]

%% Load Projections
if exist(tmpProjPath, 'file') == 2
    fprintf('Fast load: Loading it from temporary storage...\n'); 
    projections=load(tmpProjPath,'projections');
    projections=projections.projections;
    fprintf('Done.\n');
else
    fprintf('Loading it from file...\n');     
    projections=loadProjections(rawProjPath,maxNumProj,1);
    save(tmpProjPath,'projections','-v7.3');
    fprintf('Done.\n');
end

%imshow3D(projections);
%% TEST FUNCTIONS
clear proj1D;
if exist(tmpProj1DPath, 'file') == 2
    fprintf('Fast load: Loading 1D Projections from temporary storage...\n'); 
    proj1D=load(tmpProj1DPath,'proj1D');
    proj1D=proj1D.proj1D;
    fprintf('Done.\n');    
else
    fprintf('Calculating 1D projection ...\n'); 
    [proj1D] = get1DProjections(projections);
    save(tmpProj1DPath,'proj1D','-v7.3');
    fprintf('Calculation Done.\n');
end
%%

gproj1D=gpuArray(proj1D);
%%
tic
p1=gproj1D(:,:,1);
p2=gproj1D(:,:,2);
p1=p1(1:180,:);
p1_4=permute(p1,[3 2 1]);
[phi_ij,phi_ji,val,~] = findPhiBtwTwoProj2(p1_4,p2)
toc
%% 
[phi] = getPhi(gproj1D);
%%
if exist(tmpPhiPath, 'file') == 1
    fprintf('Fast load: Loading phi from temporary storage...\n'); 
    phi=load(tmpPhiPath,'phi');
    phi=phi.phi;
    fprintf('Done.\n');
else
    fprintf('Calculating phi...\n');   
    gproj1D=gpuArray(proj1D);
    [phi,error] = getPhi(gproj1D);
    %clear gproj1D;
    %save(tmpPhiPath,'phi','-v7.3');
    fprintf('Done.\n');
end


%% Delete parallel pool
 p = gcp;
delete(p)
%% GPU
d=gpuDevice(1);
reset(d)

%%
tic
clear p1 p2 pp
pp=proj1D;
p1=gpuArray(pp(:,:,1));
p1_4=permute(p1,[3 2 1]);
p2=gpuArray(pp(:,:,2:20));
p2=permute(p2,[1 2 4 3]);
p2=repmat(p2,1,1,360);
c1=bsxfun(@minus,p2,p1_4);
c1=sum(abs(c1),2);
c1=permute(c1,[3 1 4 2]);
n=size(p1,2);
%c2=c1(:,:,1)./n;
toc





