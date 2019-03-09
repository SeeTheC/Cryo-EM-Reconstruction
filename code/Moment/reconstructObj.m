function [objFBP] = reconstructObj(projections,angles,emDim)
<<<<<<< HEAD
    %% INIT
    N=size(angles,2);
    projections=projections(:,:,1:N);
=======
   
>>>>>>> 84a39d7eaf66bffde88ab4024e724c8b83d4bbbb
    %% Define Geometry
    % 
    % VARIABLE                                   DESCRIPTION                    UNITS
    %-------------------------------------------------------------------------------------
    %geo.DSD = 1536;                             % Distance Source Detector     (mm)
    geo.DSD = 1000;                             % Distance Source Detector      (mm)
    geo.DSO = 500;                             % Distance Source Origin        (mm)
    % Detector parameters
<<<<<<< HEAD
    geo.nDetector=[128; 128];					% number of pixels              (px)
    geo.dDetector=[1; 1]; 					% size of each pixel            (mm)
=======
    geo.nDetector=[256; 256];					% number of pixels              (px)
    geo.dDetector=[0.8; 0.8]; 					% size of each pixel            (mm)
>>>>>>> 84a39d7eaf66bffde88ab4024e724c8b83d4bbbb
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


    %% Reconstruct image using OS-SART and FDK
    tic
    fprintf('Reconstructing..\n');
    geoFBP=checkGeo(geo,angles);
    objFBP=FBP(projections,geoFBP,angles);
    %%imgAx=Atb(projections,geoFBP,angles);
    %error=em-imgFDK;
    toc
    fprintf('Done\n');
end

