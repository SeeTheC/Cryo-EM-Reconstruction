% Converts image (2d) to vector (1d)
% Author: Khursheed Ali
% Date: 6nd Mar 2019, 2:28 AM

function [features] = feature0_imgToVector(images,config)
    %% INIT 
    N=size(images,3);
    downsample=config.downsample;
    %% Process
    parfor i=1:N
        img=images(:,:,i);
        img=imresize(img,1/downsample);
        features(i,:)=img(:)';
    end
end

