% This script illustrates the basic ab initio reconstruction functionality of
% the ASPIRE toolbox on simulated data, using common lines to recover the
% viewing angles from clean images and reconstructing the volume using the
% least-squares volume estimator.

%% % Parameters %%%

L = 65;                 % Size of images.
n = 100;                % Number of images.

SNR = 32;               % Signal-to-noise ratio of images.

n_r = ceil(L/2);        % Number of radial nodes in polar Fourier transform.
n_theta = 360;           % Number of angular nodes in polar Fourier transform.

%%% Simulate data %%%

% Load the 'cleanrib' volume, corresponding to the experimentally obtained EM
% map of a 50S ribosome.
root = aspire_root();
file_name = fullfile(root, 'projections', 'simulation', 'maps', 'cleanrib.mat');
f = load(file_name);
vol_true = cryo_downsample(f.volref, L*ones(1, 3));

%% TEMP
n = 100;
L = 150;
n_r = ceil(L/2);     
n_theta = 360; 
vol_true=em;
%vol_true = cryo_downsample(vol_true, L*ones(1, 3));

%% Generate random rotations. These are the true viewing directions.
tic

rots_true = rand_rots(n);
inv_rots_true = invert_rots(rots_true);
%%
fprintf('Finding Projections ... \n');
% Generate clean image by projecting volume along rotations.
ims_clean = cryo_project(vol_true, rots_true);

% `cryo_project` does not generate images compatible with the other functions in
% the package, so we need to switch the x and y axes.
ims_clean = permute(ims_clean, [2 1 3]);

ims=ims_clean;

fprintf('Done.\n');
toc
%% 
obj=em;
angles=rotm2eul(rots_true,'ZYX');
objSize=size(obj)';

%% TIGRE : RECONS
emDim=[128;128;128];
noOfProj=n;
p2=permute(ims, [2 1 3]);
p=p2;

trueAngles=rotm2eul(inv_rots_true,'ZYX')'; % working
angles=trueAngles;

%predAngles=rotm2eul(permute(inv_rots_aligned,[2 1 3]),'ZYX')';
%angles=predAngles;

%inv_rots_aligned = align_rots(predR,inv_rots_true);

%predAngles=rotm2eul(inv_rots_aligned,'ZYX')'; 
%angles=predAngles;

%angles(3,:)=angles(3,:)-pi/2;
angles(2,:)=angles(2,:)+pi/2;
%angles(1,:)=angles(1,:)+pi/2;

[objFBP]=reconstructObj(p(:,:,1:noOfProj),angles(:,1:noOfProj),emDim);
figure, imshow3D(objFBP)
%%
[trueObjFBP]=reconstructObj(p(:,:,1:noOfProj),trueAngles(:,1:noOfProj),emDim);
figure, imshow3D(trueObjFBP);


%% REC:
tic
% Set up parameters for volume estimation.
params = struct();
params.rot_matrices = inv_rots_true;     % Estimated rotations.

params.ctf = ones(L*ones(1, 2));            % CTFs (none here).
params.ctf_idx = ones(1, n);                % CTF indices (all the same).
params.ampl = ones(1, n);                   % Amplitude multipliers (all one).
params.shifts = zeros(2, n);                % Shifts (none here).

% Set up basis in which to estimate volume. Here, it is just the standard Dirac
% basis, where each voxel is a basis vector.
basis = ffb_basis(L*ones(1, 3));

fprintf('Reconstruction.\n');
% Set up options for the volume estimation algorithm.
mean_est_opt = struct();
mean_est_opt.verbose = true;               % Don't output progress info.
mean_est_opt.max_iter = 10;                 % Maximum number of iterations.
mean_est_opt.rel_tolerance = 1e-3;          % Stopping tolerance.
mean_est_opt.half_pixel = true;             % Center volumes around half pixel.
%mean_est_opt.verbose = 1;                   % Print progress information.

% Estimate volume using least squares.
vol_est = cryo_estimate_mean(ims, params, basis, mean_est_opt);
fprintf('Done.\n');
toc
figure, imshow3D(vol_est)

%% Add noise at desired SNR.
power_clean = tnorm(ims_clean).^2/numel(ims_clean);
sigma_noise = sqrt(power_clean/SNR);
ims = ims_clean + sigma_noise*randn(size(ims_clean));

%% TEMP
n_theta=360;
n_r=50;
rots_true=trueRotMat;
ims= permute(projections,[2 1 3]);
%% Finding common line
tic
fprintf('Finding common line ... \n');
% Calculate polar Fourier transforms of images.
pf = cryo_pft(ims, n_r, n_theta);
% Estimate common-lines matrix.
clstack_est = cryo_clmatrix(pf);
toc
fprintf('Done.\n');
%%
% Calculate the "true" common-lines matrix from true rotations.
clstack_true = clmatrix_cheat(rots_true, n_theta);

% Compare common lines computed from projections to the reference common
% lines. A common line is considered correctly-identified if it deviates
% from the true common line between the projections by up to 10 degrees.
prop=comparecl( clstack_true, clstack_est, n_theta, 1 );
fprintf('Percentage of correct common lines: %f%%\n\n',prop*100);
fprintf('Done.\n');

%% MY : 
projections=permute(ims,[2 1 3]);
[proj1D] = get1DProjections(projections);
gproj1D=gpuArray(proj1D);
tic
[phi,error] = getPhi(gproj1D);
phi=phi+1;
phi(1:1+size(phi,2):end)=0;
toc
clear gproj1D;
fprintf('Done\n');


%% % Estimate viewing angles %%%

% Construct syncronization matrix from common lines.
S_est = cryo_syncmatrix_vote(clstack_est, n_theta);
%S_est = cryo_syncmatrix_vote(phi, n_theta);

% Estimate rotations using synchronization.
inv_rots_est = cryo_syncrotations(S_est);


% Align our estimates rotations to the true ones. This lets us compute the MSE,
% but also allows us to more easily compare the reconstructed volume.
inv_rots_aligned = align_rots(inv_rots_est, inv_rots_true);

fprintf('Done.\n');
%% % Estimate volume %%%
tic
% Set up parameters for volume estimation.
params = struct();
params.rot_matrices = inv_rots_aligned;     % Estimated rotations.

params.ctf = ones(L*ones(1, 2));            % CTFs (none here).
params.ctf_idx = ones(1, n);                % CTF indices (all the same).
params.ampl = ones(1, n);                   % Amplitude multipliers (all one).
params.shifts = zeros(2, n);                % Shifts (none here).

% Set up basis in which to estimate volume. Here, it is just the standard Dirac
% basis, where each voxel is a basis vector.
basis = ffb_basis(L*ones(1, 3));

% Set up options for the volume estimation algorithm.
mean_est_opt = struct();
mean_est_opt.verbose = false;               % Don't output progress info.
mean_est_opt.max_iter = 10;                 % Maximum number of iterations.
mean_est_opt.rel_tolerance = 1e-3;          % Stopping tolerance.
mean_est_opt.half_pixel = true;             % Center volumes around half pixel.
mean_est_opt.verbose = 1;                   % Print progress information.

% Estimate volume using least squares.
vol_est = cryo_estimate_mean(ims, params, basis, mean_est_opt);
fprintf('Done.\n');
toc
figure, imshow3D(vol_est)
%% % Evaluate results %%%

% Calculate proportion of correctly identified common lines.
cl_prop = comparecl(clstack_est, clstack_true, n_theta, 10);

% Calculate MSE of rotations.
mse_rots = tnorm(inv_rots_aligned-inv_rots_true)^2/n;

% Calculate relative MSE of volume estimation.
nrmse_vol = tnorm(vol_est-vol_true)/tnorm(vol_true);

% Reproject estimated volume and compare with clean images.
ims_est = cryo_project(vol_est, rots_true);
ims_est = permute(ims_est, [2 1 3]);

nrmse_ims = tnorm(ims_est-ims_clean)/tnorm(ims_clean);

fprintf('%-40s%20g\n', 'Proportion of correct common lines:', cl_prop);
fprintf('%-40s%20g\n', 'MSE of rotations:', mse_rots);
fprintf('%-40s%20g\n', 'Estimated volume normalized RMSE:', nrmse_vol);
fprintf('%-40s%20g\n', 'Reprojected images normalized RMSE:', nrmse_ims);
