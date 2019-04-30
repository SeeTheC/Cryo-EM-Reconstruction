%% Demo 4: Simple Image reconstruction
%
%
% This demo will show how a simple image reconstruction can be performed,
% by using OS-SART and FDK
%
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% This file is part of the TIGRE Toolbox
% 
% Copyright (c) 2015, University of Bath and 
%                     CERN-European Organization for Nuclear Research
%                     All rights reserved.
%
% License:            Open Source under BSD. 
%                     See the full license at
%                     https://github.com/CERN/TIGRE/blob/master/LICENSE
%
% Contact:            tigre.toolbox@gmail.com
% Codes:              https://github.com/CERN/TIGRE/
% Coded by:           Ander Biguri 
%--------------------------------------------------------------------------
%% Initialize

clear;
close all;
%% Define Geometry
% 
% VARIABLE                                   DESCRIPTION                    UNITS
%-------------------------------------------------------------------------------------
geo.DSD = 1536;                             % Distance Source Detector      (mm)
geo.DSO = 1000;                             % Distance Source Origin        (mm)
% Detector parameters
geo.nDetector=[256; 256];					% number of pixels              (px)
geo.dDetector=[1; 1]; 					% size of each pixel            (mm)
geo.sDetector=geo.nDetector.*geo.dDetector; % total size of the detector    (mm)
% Image parameters
geo.nVoxel=[128;128;128];                   % number of voxels              (vx)
geo.sVoxel=[256;256;256];                   % total size of the image       (mm)
geo.dVoxel=geo.sVoxel./geo.nVoxel;          % size of each voxel            (mm)
% Offsets
geo.offOrigin =[0;0;0];                     % Offset of image from origin   (mm)              
geo.offDetector=[0; 0];                     % Offset of Detector            (mm)


% Auxiliary 
geo.accuracy=1;                           % Accuracy of FWD proj          (vx/sample)
geo.mode='parallel';
%% Load data and generate projections 
% define angles
angles=linspace(0,2*pi,100);
%%
rng(1)
noOfAngles=5000;
quternion=randn(noOfAngles,4);
quternion=quternion./sqrt(sum(quternion.^2,2));
for i=1:noOfAngles
    rotMtx=quat2rotm(quternion(i,:));
    rots_true(:,:,i)=rotMtx;
end
angles=rotm2eul(rots_true)';
%% Load thorax phatom data
head=headPhantom(geo.nVoxel);
% generate projections
projections=Ax(head,geo,angles,'interpolated');
% add noise
noise_projections=addCTnoise(projections);

%% Reconstruct image using OS-SART and FDK

% FDK
imgFDK=FDK(projections,geo,angles);
% OS-SART

niter=50;
imgOSSART=OS_SART(noise_projections,geo,angles,niter);

% Show the results
plotImg([imgFDK,imgOSSART],'Dim','Z');
