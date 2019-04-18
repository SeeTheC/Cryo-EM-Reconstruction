% Crop the 3D objection from center
% Author: Khursheed Ali
function [newObj] = imcrop3D(obj,radius)    
    n=size(obj,3);
    [H,W]=size(obj(:,:,1));
    x1=ceil(H/2-radius);y1=ceil(W/2-radius);
    sx=max(ceil(n/2-radius),0);ex=min(ceil(n/2+radius),n);
    j=1;    
    for i=sx:ex    
        newObj(:,:,j)= imcrop(obj(:,:,i),[y1 x1 radius*2 radius*2]);
        j=j+1;
    end
end

