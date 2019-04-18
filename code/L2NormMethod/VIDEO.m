%% TO BE RUN AFTER Running Main
%% Config
clear all;
server = 1;
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Reconstruction/code/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end


% EM-8647 - downsample by 2 
dirpath=strcat(basepath,'/8647/Projection_8647_Td2_GaussainNoise_percent_30/Result/proj501_soff10_itr20');

% EM-1050 - downsample by 2 
%dirpath=strcat(basepath,'/1050/Projection_1050_TCrp20/Result/proj500_soff10_itr20');


%% Read Result

filepath=strcat(dirpath,'/final_result.mat');
s=load(filepath);
fr=s.result;
%% Record Video
clear F;
trueObj=fr.config.trueObj;
initReconstObj=fr.f_init;
myReconstObj=fr.f_final;

frameNo=1;
N=size(myReconstObj,3);
fig2=figure('units','normalized','outerposition',[0 0 1 1]);
pause(5);

%trueObj = trueObj-min(trueObj(:));
%trueObj = trueObj./max(trueObj(:));

minTrue=min(trueObj(:));maxTrue=max(trueObj(:));
minInit=min(initReconstObj(:));maxInit=max(initReconstObj(:));
minMyVal=min(myReconstObj(:));maxMy=max(myReconstObj(:));

for i=1:N      
    subplot(1,3,1)
    %imshow(trueObj(:,:,i),[minTrueClrVal maxTrueClrVal]),colorbar;
    imshow(trueObj(:,:,i),[0 maxTrue]),colorbar; 
    tstr=sprintf('\\fontsize{14}{\\color{black} True. Z:%d/%d}',i,N);
    title(tstr);
    
    subplot(1,3,2)
    %imshow(reconstObj(:,:,i),[minRecontClrVal maxRecontClrVal]),colorbar;
    imshow(initReconstObj(:,:,i),[0 maxInit]),colorbar;    
    tstr=sprintf('\\fontsize{14}{\\color{orange} Init-Estimate Z:%d/%d}',i,N);
    title(tstr);
    
    
    subplot(1,3,3)
    %imshow(reconstObj(:,:,i),[minRecontClrVal maxRecontClrVal]),colorbar;
    imshow(myReconstObj(:,:,i),[0 maxMy]),colorbar;    
    tstr=sprintf('\\fontsize{14}{\\color{magenta} Result Z:%d/%d}',i,N);
    title(tstr);
    
    
    %pause(0.5);
    F(frameNo)=getframe(fig2);frameNo=frameNo+1;
end
%% Record Video
%F2=[F1,F];
F2=F;
fprintf('Creating Video.\n');
% create the video writer with 1 fps
%writerObj = VideoWriter('reconstruction_700_rand.avi');
writerObj = VideoWriter(strcat(dirpath,'/video.avi'));
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


