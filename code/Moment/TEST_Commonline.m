% Test common-line
%% INIT
clear all;
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
addpath(genpath('../FileOperation'));
addpath(genpath('../CommonFunctions'));
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
dataNum = 2222;
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
 em(em<0)=0;
 emDim=size(em)'; 
 fprintf('Dataset:%d Dim:%dx%dx%d\n',dataNum,emDim(1),emDim(2),emDim(3));
 
%% Set Paths
parentDirPath=strcat(basepath,'/',num2str(dataNum));

%subDirPath=strcat(parentDirPath,'/Projection_',num2str(dataNum),'_rnd');
subDirPath=strcat(parentDirPath,'/Projection_',num2str(dataNum),'_guassina_dis_Quat');


rawProjPath=strcat(subDirPath,'/raw_img');
maxNumProj=2000;
tmpsaveDir=strcat('TmpSave/',num2str(dataNum));
mkdir(tmpsaveDir);
suffix='_guassina_dis_Quat_2000';
%suffix='_c_500';
tmpProjPath=strcat(tmpsaveDir,'/tmp_result/projections',suffix,'.mat');
tmpProj1DPath=strcat(tmpsaveDir,'/tmp_result/proj1D',suffix,'.mat');
tmpPhiPath=strcat(tmpsaveDir,'/tmp_result/phi',suffix,'.mat');
tmpTruePhiPath=strcat(tmpsaveDir,'/tmp_result/truePhi',suffix,'.mat');
tmpTrueSPath=strcat(tmpsaveDir,'/tmp_result/trueS',suffix,'.mat');

%%
PP1f=[
        1,2,3,4,5;
        6,34,23,56,10;
        14,67,89,13,65;
        43,56,34,78,6;
        12,67,98,45,23;    
    ];

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
trueAngles=load(strcat(subDirPath,'/angles.mat'),'angles');
trueAngles=trueAngles.angles;
trueAngles=trueAngles(:,1:maxNumProj);
[trueRotMat] = convertAngleToRotMat(trueAngles');

%imshow3D(projections);
%% Load/Find 1D Projections
clear proj1D;
if exist(tmpProj1DPath, 'file') == 1
    fprintf('Fast load: Loading 1D Projections from temporary storage...\n'); 
    proj1D=load(tmpProj1DPath,'proj1D');
    proj1D=proj1D.proj1D;
    fprintf('Done.\n');    
else
    fprintf('Calculating 1D projection ...\n'); 
    [proj1D] = get1DProjections(projections);
    %save(tmpProj1DPath,'proj1D','-v7.3');
    fprintf('Calculation Done.\n');
end

%%

gproj1D=gpuArray(proj1D);
%%
tic
p1d1=proj1D(:,:,1);
p1d2=proj1D(:,:,3);
p1d1=p1d1(1:1791,:);
[phi_ij,phi_ji,val,~] = findPhiBtwTwoProj(p1d1,p1d2)
% 149.5000 183.7000
%p1_4=permute(p1,[3 2 1]);
%[phi_ij,phi_ji,val,~] = findPhiBtwTwoProj2(p1_4,p2);
toc
%% 
[phi] = getPhi(gproj1D);
%% Load/Find phi

if exist(tmpPhiPath, 'file') == 2
    fprintf('Fast load: Loading phi from temporary storage...\n'); 
    phi=load(tmpPhiPath,'phi');
    phi=phi.phi;
    fprintf('Done.\n');
else
    fprintf('Calculating phi...\n');   
    gproj1D=gpuArray(proj1D);
    [phi,error] = getPhi(gproj1D);
    clear gproj1D;
    save(tmpPhiPath,'phi','-v7.3');
    fprintf('Done.\n');
end

%% Calculate True S and Phi

if exist(tmpTruePhiPath, 'file') == 1
    fprintf('Fast load: Loading phi from temporary storage...\n'); 
    truePhi=load(tmpTruePhiPath,'truePhi');
    truePhi=truePhi.truePhi;
    truePhiDeg=truePhi.*(180/pi);
    fprintf('Done.\n');
else
    fprintf('Calculating truePhi ...\n');       
    [trueS,truePhi] = ASINGER2011_GetS_TESTFun(trueRotMat); 
    truePhiDeg=truePhi.*(180/pi);
    %save(tmpTruePhiPath,'truePhi','-v7.3');
    %save(tmpTrueSPath,'trueS','-v7.3');
    fprintf('Done.\n');
end

%% TESING COMMONLINE
pidx1=1;pidx2=2;
p1=projections(:,:,pidx1);
p2=projections(:,:,pidx2);
%[c1,~,~,fftP1]=getCommonlineValues(p1,phi(pidx1,pidx2));
%[c2,~,~,fftP2]=getCommonlineValues(p2,phi(pidx2,pidx1));
%error=RMSE(c1,c)
%absError=abs(error)
%%
[c3,~,~,fftP3]=getCommonlineValues(p1,90);
[c4,~,~,fftP4]=getCommonlineValues(p5,45+90);
error=RMSE(c3,c4)
absError=abs(error)
%%
[fphi_ij,fphi_ji,frmsError] = findPhiBtwTwoProj3UsingFT(p1,p3)
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

%% TESTING: FIND C
[C1,C2] = findC(phi);

%%
D1=normc(C1');D2=normc(C2');

%D1=C1';D2=C2';

dr=(180/pi);

Q=getRotMtx(D2(:,1),D1(:,1))

D3=Q*D2;

v1=normc(cross(D1(:,1),D1(:,2)))
v2=normc(cross(D3(:,1),D3(:,2)))

%v1=acos(normc(cross(D1(:,1),D1(:,2)))).*dr
%v2=acos(normc(cross(D3(:,1),D3(:,2)))).*dr

%% Example
%plane 1: YZ
%plane 2: XY
%plane 3: ZX
%plane 4: ZX with 45. with XY.

A=[0,0,1;1,0,0;0,1,0]; A=A';
B=[0,0,1;1,1/sqrt(2),0;0,1/sqrt(2),0]; B=B';
phiAB=[0,0,90,45;
       0,0,270,270;
       90,180,0,180;
       0,180,180,0];
   
M1 = A*A';
[U,S1,~]=svds(M1);
C1=U*(S1^0.5);

M2 = B*B';
[U2,S2,V2]=svds(M2);
C2=U2*(S2^0.5);

%% 
D1=normc(C1');D2=normc(C2');

dr=(180/pi);

Q=getRotMtx(D1(:,1),D2(:,1))

D3=Q'*D2;

v1=normc(cross(D1(:,1),D1(:,2)))
v2=normc(cross(D3(:,1),D3(:,2)))

%%
C11=normc(C1');C22=normc(C2');

dr=(180/pi);

D11=normc(cross(C11(:,1),C11(:,2)))
D12=normc(cross(C11(:,1),C11(:,3)))

D21=normc(cross(C22(:,1),C22(:,2)))
D22=normc(cross(C22(:,1),C22(:,3)))

% aplha_12 angle between  plane 1 and 2
% aplha_12_1 should be equal to aplha_12_2
aplha_12_1 = acos(dot(D11,D12))*dr
aplha_12_2 = acos(dot(D21,D22))*dr

%% Example 
O(:,:,1)=[1,2,3;4,5,6;7,8,9]
O(:,:,2)=[10,11,12;13,14,15;16,17,18]
O(:,:,3)=[19,20,21;22,23,24;25,26,27]

%plane 1: YZ : [0,0,0]
p1=[0,0,0,0,0;
    0,O(1,:,1)+O(1,:,2)+O(1,:,3),0;
    0,O(2,:,1)+O(2,:,2)+O(2,:,3),0;
    0,O(3,:,1)+O(3,:,2)+O(3,:,3),0;
    0,0,0,0,0;]

%plane 2: XY : [0,180,0]
p2=[0,0,0,0,0;
    0,squeeze(O(1,1,:)+O(2,1,:)+O(3,1,:))',0;
    0,squeeze(O(1,2,:)+O(2,2,:)+O(3,2,:))',0;
    0,squeeze(O(1,3,:)+O(2,3,:)+O(3,3,:))',0;
    0,0,0,0,0;];

p2=p2'

%plane 3: ZX : [90,0,0]
p3=[0,0,0,0,0;
    0,squeeze(O(1,1,:)+O(1,2,:)+O(1,3,:))',0;
    0,squeeze(O(2,1,:)+O(2,2,:)+O(2,3,:))',0;
    0,squeeze(O(3,1,:)+O(3,2,:)+O(3,3,:))',0;
    0,0,0,0,0;
    ]

p4=[0,7,16,25,0;
    0,12,30,18,0;
    0,15,42,69,0;
    0,8,26,44,0;
    0,3,12,21,0;
    ]

p5= [  0,0,0,0,0;
       7,24,61,44,27;
       4,18,42,38,24;
       1,12,33,32,21;
       0,0,0,0,0;
    ]
cubeAng=[180,90,90;
         90,90,0;
         90,180,90;         
        ]
cubeAng=cubeAng'.*(pi./180);
clear P;
P(:,:,1)=p1;P(:,:,2)=p2;P(:,:,3)=p3;P(:,:,4)=p4;P(:,:,5)=p5;
%P(:,:,4)=p4;
%%
[P1D] = get1DProjections(P);
gP1D=gpuArray(P1D);
[ex_phi,ex_error] = getPhi(gP1D);
[C1,C2] = findC(ex_phi);
%% TEST CUBE

[cubeRotMat] = convertAngleToRotMat(cubeAng');
cubeRotMatZYZ=eul2rotm(cubeAng','ZYZ');
[cubeTrueS,cubeTruePhi] = ASINGER2011_GetS_TESTFun(cubeRotMatZYZ); 
cubeTruePhiDeg=cubeTruePhi.*(180/pi);
[cubeproj1D] = get1DProjections(P);
[cubePhi,error] = getPhi(cubeproj1D);
fprintf('Done.\n');
%% TEST CUBE
p1d1=cubeproj1D(:,:,1);
p1d2=cubeproj1D(:,:,2);
p1d1 = p1d1(1:180,:);
[phi_ij,phi_ji,val,~] = findPhiBtwTwoProj(p1d1,p1d2);
%% TEST A. SINGER 2011
fprintf('Finding S:\n');
%S=ASINGER2011_GetS_step1(phi);
S=ASINGER2011_GetS_step1(truePhi);
%S=trueS;
fprintf('Done.\n');
%%
fprintf('Finding rotation matrix\n');
[predR,ZYZ,U,Sv,V] = ASINGER2011_GetR_step2(S,size(phi,1));
fprintf('Done.\n');
%% Fing Global Rotation
fprintf('Finding Global tranformation matrix\n');
[trueRotMat] = convertAngleToRotMat(trueAngles');
[gobalRotMat] = getGlobalRotTransformation(trueRotMat,predR);
[newPredR,newZYZ] = transformRot(gobalRotMat,predR);
fprintf('Done.\n');
%% Reconstruct image using OS-SART and FDK
emDim=[160,160,160]';
p=single(projections);
[reconstObjFBP] = reconstructObj(p,newZYZ,emDim);
[trueObjFBP]=reconstructObj(p,trueAngles,emDim);
imshow3D(reconstObjFBP);
%% TEMP
fprintf('TEMP : Finding Global tranformation matrix\n');

[truePredR,~,trueU,trueSv,trueV] = ASINGER2011_GetR_step2(trueS,size(phi,1));

[trueRotMat] = convertAngleToRotMat(trueAngles');
[trueGobalRotMat] = getGlobalRotTransformation(trueRotMat,truePredR);
[trueNewPredR,trueNewZYZ] = transformRot(trueGobalRotMat,truePredR);
[trueReconstObjFBP] = reconstructObj(p,trueNewZYZ,emDim);
imshow3D(trueReconstObjFBP);

fprintf('TEMP: Done.\n');

%% Record Video
clear F;
frameNo=1;
N=size(reconstObjFBP,3);
fig2=figure('units','normalized','outerposition',[0 0 1 1]);
pause(5);
minClrVal=min(trueObjFBP(:));maxClrVal=max(trueObjFBP(:));
for i=1:N      
    subplot(1,2,1)
    imshow(trueObjFBP(:,:,i),[minClrVal maxClrVal]),colorbar;
    tstr=sprintf('\\fontsize{14}{\\color{black}Original Z:%d/%d}',i,N);
    title(tstr);
    
    subplot(1,2,2)
    imshow(reconstObjFBP(:,:,i),[minClrVal maxClrVal]),colorbar;
    tstr=sprintf('\\fontsize{14}{\\color{magenta}Reconstruction Z:%d/%d}',i,N);
    title(tstr);
    %pause(0.5);
    F(frameNo)=getframe(fig2);frameNo=frameNo+1;
end
%% Record Video
%F2=[F1,F];
F2=F;
fprintf('Creating Video.\n');
% create the video writer with 1 fps
%writerObj = VideoWriter('reconstruction_700_rand.avi');
writerObj = VideoWriter(strcat(subDirPath,'/proj_uniform_2000_2_truePhi.avi'));

writerObj.FrameRate = 2;% set the seconds per image

% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(F2)
    % convert the image to a frame
    frame = F2(i) ;    
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);
fprintf('Done.\n');


%%  TESTING CODE


[S] = ASINGER2011_GetS_TESTFun(trueRotMat);