%% Generate Sample projection from the 3D structure ans the projections
%% INIT - Reading Data Set
clear all;
%addpath(genpath('../../lib/aspire-v0.14-0'));
addpath(genpath('../CommonFunctions'));
% EMD 3D Projection -  Init
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
callPath=pwd;
cd('../../lib/CERN-TIGRE/MATLAB'); 

server = 1
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Reconstruction/code/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end
funInitTIGRE();
cd(callPath); 

%% Config 1: Reading Emd virus
 dataNum = 4138;
 datasetName=num2str(dataNum);
 datasetPath='~/git/Dataset/EM';
  if(dataNum==1003)
        emFile=strcat(datasetPath,'/EMD-1003','/map','/emd_1003.map'); 
        em = mapReader(emFile);
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
    %em=imresize3(em,1/2);
    %[em] = imcrop3D(em,36);
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
 if(dataNum==2198) 
    emFile=strcat(datasetPath,'/EMD-2198','/map','/EMD-2198.map');
    em = mapReader(emFile);
 end 
 if(dataNum==1050) 
    emFile=strcat(datasetPath,'/EMD-1050','/map','/EMD-1050.map');
    em = mapReader(emFile);
 end 
 if(dataNum==8647) 
     % 128x128x128
    emFile=strcat(datasetPath,'/EMD-8647','/map','/EMD-8647.map');
    em = mapReader(emFile);
 end
  if(dataNum==76) 
    % 360x360x360
    emFile=strcat(datasetPath,'/EMD-0076','/map','/EMD-0076.map');
    em = mapReader(emFile);
 end
 
 if(dataNum==70)
    root = aspire_root();
    file_name = fullfile(root, 'projections', 'simulation', 'maps', 'cleanrib.mat');
    em = load(file_name);
    em=em.volref;
    em=single(em);
 end
 
 em(em<0)=0;
 emDim=size(em)'; 
 fprintf('Dataset:%d Dim:%dx%dx%d\n',dataNum,emDim(1),emDim(2),emDim(3));
%% CROPPING
I=em(:,:,40);
[H,W]=size(I);
radius=18;
x1=ceil(H/2-radius);
y1=ceil(W/2-radius);
I2 = imcrop(I,[y1 x1 radius*2 radius*2]);
imshow(I2,[]);
%% Croping object
[em] = imcrop3D(em,20);
%%
downsample=2;
em=imresize3(em,1/downsample);
%% Config 2: Set Save Paths
suffix='';
timestamp=datestr(now,'dd-mm-yyyy-HH_MM_SS');
saveParentPath=strcat(basepath,'/',datasetName,suffix);
savepath=strcat(saveParentPath,'/Projection_',num2str(dataNum),'_',timestamp); 
savedImgDir=strcat(savepath,'/img');
savedRawImgDir=strcat(savepath,'/raw_img');


% Creating dir
mkdir(saveParentPath);
mkdir(savepath);
mkdir(savedImgDir);
mkdir(savedRawImgDir);

% creating a file
fid = fopen(strcat(savepath,'/0_info.txt'), 'a+');
fprintf(fid, 'img_no \t min_val \tmax_val \t ang_x \t ang_y \t ang_z \n');

%% Taking Projection

%% Projection Angles 1
% define projection angles (in radians)
noOfAngles=5000;
isRand=true;
anglesX=linspace(0,2*pi,noOfAngles);
anglesY=linspace(0,2*pi,noOfAngles);
anglesZ=linspace(0,2*pi,noOfAngles);
rng(1);
if isRand
    randian=pi/180;
    angX=randi([0 359],1,noOfAngles).*randian;
    angY=randi([0 359],1,noOfAngles).*randian;
    angZ=randi([0 359],1,noOfAngles).*randian;
    angles=[angX;angY;angZ]; 
else
    angles=[anglesX;anglesY;anglesZ];   
end
%x=[0,0,0,0,pi/2,pi/2];
%y=[0,pi/2,pi/2 0,pi/2,pi/2];
%z=[0,0,pi/2,pi/2,0,pi/2];
%angles=[x;y;z];   
%% Projection Angles 2: Guassian Distribution & quternion
noOfAngles=1005;
quternion=randn(noOfAngles,4);
quternion=quternion./sqrt(sum(quternion.^2,2));
for i=1:noOfAngles
    rotMtx=quat2rotm(quternion(i,:));
    rots_true(:,:,i)=rotMtx;
end
angles=rotm2eul(rots_true)';
%% Projection Angles 3: Manual Angles with only 90deg rotation

x=[0,0,0,0,pi/2,pi/2];
y=[0,pi/2,pi/2 0,pi/2,pi/2];
z=[0,0,pi/2,pi/2,0,pi/2];
angles=[x;y;z];
angles=[    0,      0,      0;
            pi/2,   0,      0;
            0,      pi/2,   0;
            0,      0,      pi/2;
            pi/2,   pi/2,   0;
            pi/2,   0,      pi/2;
            0,      pi/2,   pi/2;
            pi/2,   pi/2,   pi/2;
            
            pi,     pi,      pi;
            pi/2,   pi,      pi;
            pi,     pi/2,    pi;
            pi,     pi,      pi/2;
            pi/2,   pi/2,    pi;
            pi/2,   pi,      pi/2;
            pi,     pi/2,    pi/2;
            pi/2,   pi/2,    pi/2;
            
        ];
angles=angles';
%% Take projection: USING TIGRE
fprintf('Taking projection...\n');
tic
projections=takeProjectionWraper(em,rots_true);
toc
fprintf('Done\n');
% Plot Projections
fprintf('Ploting Projection...\n');
%plotProj(projections,angles,'Savegif','pro_anglesXYZ11_rand.gif')
fprintf('Done\n');

%% Take projection: USING ASPIRE 
tic
n=10000;
rots_true = rand_rots(n);
angles=rotm2eul(rots_true)';
save(strcat(savepath,'/rots_true.mat'),'rots_true');

fprintf('Taking projection...\n');

% Generate clean image by projecting volume along rotations.
projections = cryo_project(em, rots_true);

fprintf('Done\n');
toc
%% Save Projection
N=size(projections,3);
fprintf('Saving total Projections: %d ...\n',N);
%fprintf(fid,'NOTE: Projections are taken from ASPIRE');

%fig3=figure('units','normalized','outerposition',[0 0 1 1]);
for i=1:N          
    img=projections(:,:,i);
    %imshow(img,[]);
    % saving raw img
    save(strcat(savedRawImgDir,'/',num2str(i),'.mat'),'img');    
    maxValue=max(img(:)); 
    minValue=min(img(:)); 
    img=img-minValue;
    
    %Saving img
    imwrite(img./maxValue,strcat(savedImgDir,'/',num2str(i),'.jpg'));
    % writing to file
    fprintf(fid, '%d \t %f \t %f \t %f \t %f \t %f \n',i,minValue, maxValue,angles(1,i),angles(2,i),angles(3,i));
    
end
save(strcat(savepath,'/angles.mat'),'angles');
save(strcat(savepath,'/rots_true.mat'),'rots_true');
fprintf('Done\n');
fclose(fid);

%%



 