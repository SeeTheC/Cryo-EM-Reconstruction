%% EMD 3D Projection
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
server = 1
%% Reading Emd virus
 dataNum = 5693;
 datasetPath='~/git/Dataset/EM';
 em1003File=strcat(datasetPath,'/EMD-1003','/map','/emd_1003.map');
 em1003 = mapReader(em1003File);
 em5693File=strcat(datasetPath,'/EMD-5693','/map','/EMD-5693.map');
 em5693 = mapReader(em5693File);

 %%
 data=em5693;
 dim=size(data);
 
 %% 1. Creating Vol Geometry
% Param: Y,X,Z
vol_geom=astra_create_vol_geom(dim(1),dim(2),dim(3));

%% 2. Projection Geometry
det_spacing_x=0.5;det_spacing_y=0.5;
det_row_count= ceil(sqrt(sum(dim.^2))) ; 
det_col_count=ceil(sqrt(sum(dim.^2))) ;
% Angle w.r.t y axis. Plane will rotate along Z axis
angles = linspace2(0, pi, 180); 
%angles = [10, 10 + pi];
%angles=[0,pi];

%% 2.1 Description of Parrallel vec
% proj_geom = astra_create_proj_geom('parallel3d_vec',  det_row_count, det_col_count, vectors);
% Create a 3D parallel beam geometry specified by 3D vectors.
% 1. det_row_count: number of detector rows in a single projection
% 2. det_col_count: number of detector columns in a single projection
% 3  vectors: a matrix containing the actual geometry.
% 
% Each row of vectors corresponds to a single projection, and consists of:
% ( rayX, rayY, rayZ, dX, dY, dZ, uX, uY, uZ, vX, vY, vZ )
% ray : the ray direction
% d : the center of the detector
% u : the vector from detector pixel (0,0) to (0,1)
% v : the vector from detector pixel (0,0) to (1,0)

noOfAngles = numel(angles);
vectors=zeros(noOfAngles,12);
for i=1:numel(angles)
    % ray direction
    theta=angles(i);
    vectors(i,1) = sin(theta);
    vectors(i,2) = -cos(theta);
    vectors(i,3) = 0;

     % center of detector
     vectors(i,4) = 0;
     vectors(i,5) = 0;
     vectors(i,6) = 0;

     % vector from detector pixel (0,0) to (0,1)
     vectors(i,7) = cos(theta) * det_spacing_x;
     vectors(i,8) = sin(theta) * det_spacing_x;
     vectors(i,9) = 0;

     % vector from detector pixel (0,0) to (1,0)
     vectors(i,10) = 0;
     vectors(i,11) = 0;
     vectors(i,12) = det_spacing_y;
end
% 2.2 Proj

proj_geom_vec=astra_create_proj_geom('parallel3d_vec',det_row_count,det_col_count,vectors);

%% 3. GPU. Take Projection
% Create projection data from this
% dimension of proj_data = YxZxX i.e ColxAnglexRow
[proj_id, proj_data1] = astra_create_sino3d_cuda(data, proj_geom_vec, vol_geom);
astra_mex_data3d('delete', proj_id);

% Converting it into YxXxZ
projection1 = permute(proj_data1,[1,3,2]);


%% Show Image

if ~server
figure('name','EMD-5693: Angle-0 rad')
%ithProj=squeeze(proj_data(:,2,:))';
ithProj=projection1(:,:,2)';
ithProj=ithProj/max(ithProj(:)); % normalizing intensites value
imshow(ithProj);
title('\fontsize{10}{\color{magenta}EMD-5693: Angle-0 rad}');
colorbar,axis on, axis tight, xlabel('X-Axis'); ylabel('Y-Axis');
end


%%
% save img
imwrite(ithProj,'EMD-5693.jpg');

