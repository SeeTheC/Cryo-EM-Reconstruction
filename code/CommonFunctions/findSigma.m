% Tries to find sigma from the constant region. Corner of image are most
% likely to be constant
% Autor: Khursheed Ali
function [sigma] = findSigma(projections,window)
       %% INIT
       p=projections;
       [h,w,n]=size(p);
       sigma=0;
       %% Find Sigma
       for i=1:n
           img=p(:,:,i);
           c1=imcrop(img,[0,0,window(1),window(2)]);
           c2=imcrop(img,[h-window(1)+1,0,window(1),window(2)]);
           c3=imcrop(img,[0,w-window(2)+1,window(1),window(2)]);
           c4=imcrop(img,[h-window(1)+1,w-window(2)+1,window(1),window(2)]);
           s=(std(c1(:))+std(c2(:))+std(c3(:))+std(c4(:)))/4;
           sigma=sigma+s;
       end
       %% Result
       sigma=sigma/n;       
end

