% Author: Khursheed Ali
function [p] = cropProj(projections,radius)
        %% Init
        [H,W,N]=size(projections);
        radius=min(radius,min(H/2,W/2));
        r=ceil(radius);        
        %%  
        parfor i=1:N
            img=projections(:,:,i);
            p(:,:,i)=imcrop(img,[ceil(H/2-r),ceil(W/2-r),r*2-1,r*2-1]);
        end        
end

