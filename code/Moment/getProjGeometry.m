function [geo] = getProjGeometry(objDim)
    %%
    dsize=ceil(sqrt(objDim(1)^2+objDim(2)^2+objDim(3)^2));
    dsize=3;
    %% Config
    % VARIABLE                                   DESCRIPTION                    UNITS
    %-------------------------------------------------------------------------------------
    %geo.DSD = 1536;                            % Distance Source Detector     (mm)
    geo.DSD = 100;                             % Distance Source Detector      (mm)
    geo.DSO = 50;                              % Distance Source Origin        (mm)
    % Detector parameters
    geo.nDetector=[dsize; dsize];				% number of pixels              (px)
    geo.dDetector=[1; 1]; 					    % size of each pixel            (mm)
    geo.sDetector=geo.nDetector.*geo.dDetector; % total size of the detector    (mm)
    % Image parameters
    geo.nVoxel=objDim;                          % number of voxels              (vx)
    geo.sVoxel=objDim;                          % total size of the image       (mm)
    geo.dVoxel=geo.sVoxel./geo.nVoxel;          % size of each voxel            (mm)
    % Offsets
    geo.offOrigin =[0;0;0];                     % Offset of image from origin   (mm)              
    geo.offDetector=[0; 0];                     % Offset of Detector            (mm)

    % Auxiliary 
    geo.accuracy=0.5;                           % Accuracy of FWD proj          (vx/sample)

    % Projection Type : parallel/cone
    geo.mode='parallel';
    %plotgeometry(geo,-pi); 

end

