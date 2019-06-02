% Author: Khursheed Ali
% Date: 2nd June 2019
function [translation,transImg2] = findTranslation(img1,imgset2)
        %% INIT
        n=size(imgset2,3);
        [h,w]=size(img1);
        [xx, yy] = meshgrid(ceil(-h/2-1):ceil(h/2),ceil(-w/2-1):ceil(w/2));
        xx=fliplr(xx);yy=flipud(yy);
        coordSystem.xx=xx;
        coordSystem.yy=yy;
        %% Process
        translation=[];
        %parfor i=1:n
        parfor i=1:n
            img2=imgset2(:,:,i);
            [x0,y0]=findTranslationCrossFourier(img2,img1,coordSystem);            
            translation(i,:)=[x0,y0];  
            transImg2(:,:,i)=imtranslate(img2,[x0,y0]);
        end
end

