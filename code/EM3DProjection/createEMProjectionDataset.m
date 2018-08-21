%% EMD 3D Projection
clear all;
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
callPath=pwd;
cd('../../lib/CERN-TIGRE/MATLAB'); 
funInitTIGRE();
cd(callPath); 
%% Reading Emd virus
 dataNum = 5689;
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
 em(em<0)=0;
 emDim=size(em)'; 
 fprintf('Dataset:%d Dim:%dx%dx%d\n',dataNum,emDim(1),emDim(2),emDim(3));

%% Taking Projection

%% Define Geometry
% 
% VARIABLE                                   DESCRIPTION                    UNITS
%-------------------------------------------------------------------------------------
%geo.DSD = 1536;                             % Distance Source Detector     (mm)
geo.DSD = 1000;                             % Distance Source Detector      (mm)
geo.DSO = 500;                             % Distance Source Origin        (mm)
% Detector parameters
geo.nDetector=[256; 256];					% number of pixels              (px)
geo.dDetector=[0.8; 0.8]; 					% size of each pixel            (mm)
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
%plotgeometry(geo,-pi); 
%% Visualize Data
%head=headPhantom(geo.nVoxel); %default is 128^3
%head=em(geo.nVoxel); %default is 128^3
%{
    t=em;
    t=im2double(t);
    for i=1:emDim(3)
        t(:,:,i)=t(:,:,i)-min(min(t(:,:,i)));
    t(:,:,i)=t(:,:,i)./max(max(t(:,:,i)));
end
%}

plotImg(em,'Dim','Z');
%% Projection
% define projection angles (in radians)
noOfAngles=100;
isRand=true;
anglesX=linspace(0,2*pi,360*2);
randX=randi([1 360*2],1,noOfAngles);
anglesY=linspace(0,2*pi,360*2);
randY=randi([1 360*2],1,noOfAngles);
anglesZ=linspace(0,2*pi,360*2);
randZ=randi([1 360*2],1,noOfAngles);

if isRand
    angles=[anglesX(randX);anglesY(randY);anglesZ(randZ)]; 
else
    angles=[anglesX;anglesY;anglesZ];   
end
%x=[0,0,0,0,pi/2,pi/2];
%y=[0,pi/2,pi/2 0,pi/2,pi/2];
%z=[0,0,pi/2,pi/2,0,pi/2];
%angles=[x;y;z];   

% take projection
fprintf('Taking projection...\n');
tic
projections=Ax(em,geo,angles,'interpolated');
toc
fprintf('Done\n');
% Plot Projections
fprintf('Ploting Projection...\n');
plotProj(projections,angles,'Savegif','pro_anglesXYZ11_rand.gif')
fprintf('Done\n');
%% Projection
clear F;
frameNo=1;
N=size(projections,3);
fig3=figure('units','normalized','outerposition',[0 0 1 1]);
pause(2);
%minClrVal=min(rescons);maxClrVal=max(rescons);
for i=1:N          
    imshow(projections(:,:,i),[]);
    tstr=sprintf('\\fontsize{14}{\\color{black}Projection:%d/%d}',i,N);
    title(tstr);        
    pause(1);
    F(frameNo)=getframe(fig3);frameNo=frameNo+1;
end

%% Reconstruct image using OS-SART and FDK
tic
fprintf('Reconstructing..\n');
geoFBP=checkGeo(geo,angles);
imgFBP=FBP(projections,geoFBP,angles);
imgAx=Atb(projections,geoFBP,angles);
%error=em-imgFDK;
toc
fprintf('Done\n');
%%
%imgFDK=FDK(projections,geo,angles);
%fprintf('Done\n');
%% Show the results
%plotImg([em],'Dim','Z','Savegif','em.gif');
plotImg([imgFBP1],'Dim','Z');

%% Histogram of values
clear F1;
imgFBP1=imgFBP;
imgFBP1(imgFBP1<0)=0;
rescons=imgFBP1(:);
original=em(:);

fig1=figure('units','normalized','outerposition',[0 0 1 1]);
%set(gcf, 'Position', get(0, 'Screensize'));
subplot(1,2,2)
bEdge=[min(rescons):0.01:max(rescons)];
histogram(rescons,bEdge);
xticks(bEdge);
xlabel('Pixel value');
ylabel('Frequency Count');
tstr=sprintf('\\fontsize{14}{\\color{magenta} Resconstruction}');
title(tstr);

%fig=2;figure
subplot(1,2,1)
o=original*2;
bEdge=[min(o):0.01:max(o)];
histogram(o,bEdge);
xticks(bEdge);
xlabel('Pixel value');
ylabel('Frequency Count');
tstr=sprintf('\\fontsize{14}{\\color{black} Original}');
title(tstr);
pause(10);
for i=1:10
    F1(i)=getframe(fig1);
end
fprintf('Done.\n');
%% 
clear F;
em1=em.*2;
frameNo=1;
N=size(imgFBP1,3);
fig2=figure('units','normalized','outerposition',[0 0 1 1]);
pause(5);
minClrVal=min(rescons);maxClrVal=max(rescons);
for i=1:N      
    subplot(1,2,1)
    imshow(em1(:,:,i),[minClrVal maxClrVal]),colorbar;
    tstr=sprintf('\\fontsize{14}{\\color{black}Original Z:%d/%d}',i,N);
    title(tstr);
    
    subplot(1,2,2)
    imshow(imgFBP1(:,:,i),[minClrVal maxClrVal]),colorbar;
    tstr=sprintf('\\fontsize{14}{\\color{magenta}Reconstruction Z:%d/%d}',i,N);
    title(tstr);
    pause(1);
    F(frameNo)=getframe(fig2);frameNo=frameNo+1;
end
%% Record Video
%F2=[F1,F];
F2=F;
fprintf('Creating Video.\n');
% create the video writer with 1 fps
%writerObj = VideoWriter('reconstruction_700_rand.avi');
writerObj = VideoWriter('proj_rand_100_1.avi');

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

 