%% TO BE RUN AFTER Running Main
%% Config
clear all;
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
addpath(genpath('../FileOperation'));
addpath(genpath('../CommonFunctions'));
addpath(genpath('FeatureExtraction/'));
addpath(genpath('Clustering/'));
server = 1;
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Reconstruction/code/data';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP';  
end


% EM-8647 - downsample by 2 
%dirpath=strcat(basepath,'/8647/Projection_8647_Td2_trans_error5/Result_Translation/proj500_Algo2_soff10_iter20');
%dirpath=strcat(basepath,'/8647/Projection_8647_Td2_trans_error5_GaussainNoise_percent_10/Result_Translation/rmvNoise_BM3D_proj502_Algo2_soff10_iter20');

% EM-1050 - crop by 2 
%dirpath=strcat(basepath,'/1050/Projection_1050_TCrp20_GaussainNoise_percent_10/Result/proj500_soff10_iter_30');

% EM-5693 - downsample by 2 
% dirpath=strcat(basepath,'/5693/Projection_5693_GaussainNoise_percent_80/Result/proj100_soff10_iter20');

% EM-4138
%dirpath=strcat(basepath,'/4138/Projection_4138_Crp86_trans_error10_GaussainNoise_percent_30/Result_Translation/rmvNoise_BM3D_Algo2_proj502_soff10_iter10');
dirpath=strcat(basepath,'/4138/Projection_4138_Crp86_trans_error10/Result_Translation/proj500_Algo2_soff10_iter20');



%% Final Result

filepath=strcat(dirpath,'/final_result.mat');
s=load(filepath);
fr=s.result;
trueObj=fr.config.trueObj;
initReconstObj=fr.f_init;
myReconstObj=fr.f_final;

% Calculate relative MSE of volume estimation.
a=initReconstObj-trueObj;b=myReconstObj-trueObj;
init_nrmse_vol = norm(a(:))/norm(trueObj(:))
final_nrmse_vol = norm(b(:))/norm(trueObj(:))

init_tnorm_nrmse_vol_ = tnorm(a)/tnorm(trueObj)
final_tnorm_nrmse_vol = tnorm(b)/tnorm(trueObj)
infoFH=fopen(strcat(dirpath,'/0_info.txt'),'a+');

fprintf(infoFH,'\n3D obj Intial Estimate Relative MSE :%f\n',init_nrmse_vol);
fprintf(infoFH,'3D obj Final Estimate Relative MSE :%f\n',final_nrmse_vol);

fprintf(infoFH,'3D obj Intial Estimate Relative MSE (tnorm) :%f\n',init_tnorm_nrmse_vol_);
fprintf(infoFH,'3D obj Final Estimate Relative MSE (tnorm):%f\n',final_tnorm_nrmse_vol);

R_true=fr.config.rots_true;
R_init = align_rots(fr.R_init, R_true);  
R_est = align_rots(fr.R_est, R_true); 

N=size(R_true,3);
 
r1_est=0;r2_est=0;r3_est=0;
r1_init=0;r2_init=0;r3_init=0;

for i=1: size(R_true,3)
    r1_est=r1_est+acosd(dot(R_true(:,1,i),R_est(:,1,i)));
    r2_est=r2_est+acosd(dot(R_true(:,2,i),R_est(:,2,i)));
    r3_est=r3_est+acosd(dot(R_true(:,3,i),R_est(:,3,i)));
    
    r1_init=r1_init+acosd(dot(R_true(:,1,i),R_init(:,1,i)));
    r2_init=r2_init+acosd(dot(R_true(:,2,i),R_init(:,2,i)));
    r3_init=r3_init+acosd(dot(R_true(:,3,i),R_init(:,3,i)));    
end

r1_init = r1_init./N
r2_init = r2_init./N
r3_init = r3_init./N

r1_est=r1_est./N
r2_est=r3_est./N
r3_est=r2_est./N

fprintf(infoFH,'\nInitial  Rotation aCos error (r1,r2,r3): %f,%f,%f\n',r1_init,r2_init,r3_init);
fprintf(infoFH,'Estimate Rotation aCos error (r1,r2,r3): %f,%f,%f\n',r1_est,r2_est,r3_est);


% Translation
trans_true=fr.config.trans_error_true;
trans_est=fr.trans_error_est;
error=trans_true-trans_est;

avgError=mean(error)
stdError=std(error)

fprintf(infoFH,'\nEstimate  Mean Translation error in pixel (x,y): %f,%f\n',avgError(1),avgError(2));
fprintf(infoFH,'Estimate Std Translation error in pixel (x,y): %f,%f\n',stdError(1),stdError(2));

fclose(infoFH);
%%

%% Record Video
clear F;

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
    subplot(1,2,1)
    %imshow(trueObj(:,:,i),[minTrueClrVal maxTrueClrVal]),colorbar;
    imshow(trueObj(:,:,i),[0 maxTrue]),colorbar; 
    tstr=sprintf('\\fontsize{14}{\\color{black} True. Z:%d/%d}',i,N);
    title(tstr);
    
    %subplot(1,3,2)
    %%imshow(reconstObj(:,:,i),[minRecontClrVal maxRecontClrVal]),colorbar;
    %imshow(initReconstObj(:,:,i),[0 maxInit]),colorbar;    
    %tstr=sprintf('\\fontsize{14}{\\color{orange} Init-Estimate Z:%d/%d}',i,N);
    %title(tstr);
    
    
    subplot(1,2,2)
    %imshow(reconstObj(:,:,i),[minRecontClrVal maxRecontClrVal]),colorbar;
    imshow(myReconstObj(:,:,i),[0 maxTrue]),colorbar;    
    tstr=sprintf('\\fontsize{14}{\\color{magenta} Result Z:%d/%d}',i,N);
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
writerObj = VideoWriter(strcat(dirpath,'/video_maxTrue.avi'));
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


