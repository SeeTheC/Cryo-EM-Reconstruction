%% Generate Sample projection from the 3D structure ans the projections
%% INIT - Reading Data Set
clear all;
addpath(genpath('../../lib/aspire-v0.14-0'));
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
 dataNum = 8647;
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

%% Define Geometry
% 
% VARIABLE                                   DESCRIPTION                    UNITS
%-------------------------------------------------------------------------------------
%geo.DSD = 1536;                             % Distance Source Detector     (mm)
geo.DSD = 1000;                             % Distance Source Detector      (mm)
geo.DSO = 500;                             % Distance Source Origin        (mm)
% Detector parameters
geo.nDetector=[128; 128];					% number of pixels              (px)
geo.dDetector=[1; 1]; 					% size of each pixel            (mm)
geo.sDetector=geo.nDetector.*geo.dDetector; % total size of the detector    (mm)
% Image parameters
geo.nVoxel=emDim;                           % number of voxels              (vx)
geo.sVoxel=emDim;                           % total size of the image       (mm)
geo.dVoxel=geo.sVoxel./geo.nVoxel;          % size of each voxel            (mm)
% Offsets
geo.offOrigin =[0;0;0];                     % Offset of image from origin   (mm)              
geo.offDetector=[0; 0];                     % Offset of Detector            (mm)

% Auxiliary 
geo.accuracy=0.5;                           % Accuracy of FWD proj          (vx/sample)

% Projection Type : parallel/cone
geo.mode='parallel';
plotgeometry(geo,-pi); 

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
noOfAngles=20000;
quternion=randn(noOfAngles,4);
quternion=quternion./sqrt(sum(quternion.^2,2));
for i=1:noOfAngles
    [a,b,c]=quat2angle(quternion(i,:),'ZYZ');
    angles(:,i)=[a,b,c]';
end
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
projections=Ax(em,geo,angles,'interpolated');
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
%save(strcat(savepath,'/rots_true.mat'),'angles');

fprintf('Taking projection...\n');

% Generate clean image by projecting volume along rotations.
projections = cryo_project(em, rots_true);

fprintf('Done\n');
toc
%% Save Projection
N=size(projections,3);
fprintf('Saving total Projections: %d ...\n',N);
fprintf(fid,'NOTE: Projections are taken from ASPIRE');

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
fprintf('Done\n');
fclose(fid);

%%



 