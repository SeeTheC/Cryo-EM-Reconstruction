%% TEST 1
a=randi([1 100],100,100,5000);
transPiCell=squeeze(num2cell(a,[1 2]));
allProj=randi([1 100],100,100,500);
N=size(allProj,1);
fprintf('Started...\n');
tic 
corrVal=[];
parfor i=1:N
    p=allProj(:,:,i);        
    corrVal(i,:)=arrayfun(@(x)corr2(x{1},p),transPiCell);        
end
toc
fprintf('Done.\n');
%%
clear all;
img1 = imresize(imread(which('cameraman.tif')),1/4);

img1=padarray(img1,[19,19],'pre');
img1=padarray(img1,[18,18],'post');

img2 = imtranslate(img1,[10,-10]);
%%
[h,w]=size(img1)
[xx, yy] = meshgrid(ceil(-h/2):ceil(h/2-1),ceil(-w/2):ceil(w/2-1));

xx=fliplr(xx);
yy=flipud(yy);

fimg1=(fft2(img1));
fimg2=(fft2(img2));

temp=fimg1.*conj(fimg2);
ftimg= temp./abs(temp);
timg = ifftshift(ifft2((ftimg)));

[v,idx]=max(timg(:))
plot3(xx,yy,timg)
[x,y]=ind2sub(size(timg),idx)
fprintf('Tranlation x:%d y:%d\n',yy(y-1,1),xx(1,x-1));
%%
[x0,y0] = findTranslation(img1,img2)
%%  TEST 3

G=reconstructObjWarper(projections,rots_true);

p_est=takeProjectionWraper(G,rots_true);

img1=p_est(:,:,1);


%%
img1 = imtranslate(projection(:,:,1),[10,10]);
img2 = pi_est(:,:,4631);

%%

clear F;

frameNo=1;
N=size(pi_est,3);
fig2=figure('units','normalized','outerposition',[0 0 1 1]);
pause(5);

[h,w]=size(img1)
[xx, yy] = meshgrid(-h/2:h/2-1,-w/2:w/2-1);

fimg1=(fft2(img1));
sa=searchArea.*180/pi;
for i=1:N      
    img2 = pi_est(:,:,i);
    fimg2=(fft2(img2));
    temp=fimg1.*conj(fimg2);
    ftimg= temp./abs(temp);
    timg = ifft2((ftimg));
    plot3(xx,yy,timg)

    tstr=sprintf(' %d/%d : (ith-1 iteration angle) + (search offset) : x+(%d),y+(%d),z+(%d)',i,N,sa(i,1),sa(i,2),sa(i,3));
    title(tstr);        
    
    %pause(0.5);
    F(frameNo)=getframe(fig2);frameNo=frameNo+1;
end
% Record Video
%F2=[F1,F];
F2=F;
fprintf('Creating Video.\n');
% create the video writer with 1 fps
%writerObj = VideoWriter('reconstruction_700_rand.avi');
writerObj = VideoWriter(strcat('./noise_per100_video.avi'));
writerObj.FrameRate = 2;% set the seconds per image

% open the video writer
open(writerObj);
% write the frames to the video
for i=1:length(F2)
    % convert the image to a frame
    frame = F2(i) ;    
    writeVideo(writerObj, frame);
end
% close the writer object
close(writerObj);
fprintf('Done.\n');
%%

