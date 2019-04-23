%% BM3D


%%
clear all;
y = im2double(rgb2gray(imread('Cameraman256.png'))); 
figure, imshow(y);

%% Add noise
% Generate the same seed used in the experimental results of [1]
randn('seed', 0);
% Standard deviation of the noise --- corresponding to intensity 
%  range [0,255], despite that the input was scaled in [0,1]
sigma = 100;

% Add the AWGN with zero mean and standard deviation 'sigma'
z = y + (sigma/255)*randn(size(y));
figure, imshow(z);       
%% Denoise

% Denoise 'z'. The denoised image is 'y_est', and 'NA = 1' because 
%  the true image was not provided
[NA, y_est] = BM3D(1, z, sigma); 
fprintf('Done.\n');
figure, imshow(y_est); 
% Compute the putput PSNR
PSNR = 10*log10(1/mean((y(:)-y_est(:)).^2))
       