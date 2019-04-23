% Remove Noise using BM3D method
% Author: Khursheed Ali
function [rProj] = rmvNoiseWithBM3D(projections)
    %% INIT
    n=size(projections,3);
    sigma=findSigma(projections,[5,5])
    %% Remove Noise
   for i=1:n
        img=projections(:,:,i);
        minInt=min(img(:));
        img=img-minInt;
        maxInt=max(img(:));
        img=img./maxInt;
                 
        % Resetting the sigma for intensity [0 255]
        r_sigma=sigma*255/maxInt;        
        [NA,p]=BM3D(1, img, r_sigma);
        
        img1=p;
        img1=img1.* maxInt;
        img1=img1 + minInt;
        
        rProj(:,:,i)=img1;
    end
end

