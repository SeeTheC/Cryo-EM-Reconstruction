% Tries to findout the translations difference between img1 and img2.
% Fuction returns x0 & y0 as translation offset meaning if img1 is
% translated by x0 and y0 it will align with the img2
% Author: Khursheed Ali
% Date: 1st June 2019
function [x0,y0] = findTranslation(img1,img2,coordSystem)
    %% INIT
    if nargin>2
        xx=coordSystem.xx;
        yy=coordSystem.yy;
    else
        % Defining Caritains Coordinate system
        [h,w]=size(img1);
        [xx, yy] = meshgrid(ceil(-h/2):ceil(h/2-1),ceil(-w/2):ceil(w/2-1));
        xx=fliplr(xx);yy=flipud(yy);
    end
    %% Finding Translation
    fimg1=(fft2(img1));
    fimg2=(fft2(img2));

    temp=fimg1.*conj(fimg2);
    ftimg= temp./abs(temp);
    timg = ifftshift(ifft2((ftimg)));

    [v,idx]=max(timg(:));
    %plot3(xx,yy,timg)
    [x,y]=ind2sub(size(timg),idx);
    %fprintf('Tranlation x:%d y:%d\n',yy(y-1,1),xx(1,x-1));
    x0=yy(y-1,1); y0=xx(1,x-1);
end

