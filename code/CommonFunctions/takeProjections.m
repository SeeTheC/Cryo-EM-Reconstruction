% Take Projections using TIGRE
% Author: Khursheed Ali
% Date: 29th March 2019

function [projections] = takeProjections(obj,angles)
    %% INIT
    offset=30;
    emDim=size(obj)';
    %d=ceil(max(emDim(:))*sqrt(3))+ offset;
    d=ceil(max(emDim(:)));
    %% Geo Config
    % VARIABLE                                   DESCRIPTION                    UNITS
    %-------------------------------------------------------------------------------------
    %geo.DSD = 1536;                             % Distance Source Detector     (mm)
    geo.DSD = 1000;                             % Distance Source Detector      (mm)
    geo.DSO = 500;                             % Distance Source Origin        (mm)
    % Detector parameters
    geo.nDetector=[d; d];					% number of pixels              (px)
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
    %% Projection
    %fprintf('Taking projection...\n');
    %tic
    projections=Ax(obj,geo,angles,'interpolated');
    %toc
    %fprintf('Done\n');
    %% Resettig GPU DEVICE
    setGPUDevice()
end

