% Author: Khursheed Ali
% Date: 2nd June 2019
function [G_est,R_est,trans_error_est,p_est,error,iteration] = L2OptWithTransAlgo1(projections,G_init,R_init,maxLoop,searchOffest,config)
    %% Config
    %trueObj=config.trueObj;  
    radian=pi/180; 
    p_true=projections;
    n=size(p_true,3);
    G=G_init;
    R_est=R_init;        
    searchThershold=searchOffest; % x deg. means +/- x deg in x,y,z,axis    
    finalSavePath=config.finalSavePath;    
    %% Init
    %R_est=config.rots_true; %DEBUG
    %G=trueObj; % DEBUG
    infoFP=strcat(finalSavePath,'/0_info.txt');
    infoFH=fopen(infoFP,'a+');   
    
    fprintf('****************************************************\n');
    fprintf('********* Algo 2: Cross Fourier Spectrum************\n');
    fprintf('****************************************************\n');
    fprintf(infoFH,'********* Algo 2: Cross Fourier Spectrum************\n');
                
     
    tmp_p_est=takeProjectionWraper(G,R_est);
    error=findCorrelationError(config.projections,tmp_p_est);    
    fprintf('Initial Correlation:%f\n',error); 
    fprintf(infoFH,'Initial Correlation:%f\n',error);     
    fprintf('Rotation Search offset:%f\n',searchOffest);
    fprintf(infoFH,'Rotation Search offset:%f\n',searchOffest);
    
    searchArea=getSearchSpace(searchThershold).*radian; 
      
    
    %% Optimization
   
    timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
    fprintf('%s\tOptimization started \n',timestamp);
    fprintf(infoFH,'%s\tOptimization started \n',timestamp);
    ithError(1)=error;      
    trans_error_est=zeros(n,2);
    p_est=p_true;
    for i=1:maxLoop        
        %parfor pIdx=1:n
        changeCount=0;
        
        for pIdx=1:n
            %fprintf(repmat('\b', 1, outPrintSize));
            %outPrintSize = fprintf('iter:%d p_idx:%d\n',i,pIdx);
            
            pi_t=p_est(:,:,pIdx);
            r=R_est(:,:,pIdx);             
            ang=rotm2eul(r);
            angSearch=bsxfun(@plus,searchArea,[ang(1) ang(2) ang(3)]);
            rotSearch=eul2rotm(angSearch);
            pi_est=takeProjectionWraper(G,rotSearch);                        
            
            % finding Rotation and Translation                        
            [translation,trans_pi_est] = findTranslation(pi_t,pi_est);
            [idx,v] = findMaxCorrProj(trans_pi_est,pi_t);
            ith_trans_est=translation(idx,:);
            R_est(:,:,pIdx)=rotSearch(:,:,idx);
            p_est(:,:,pIdx)=imtranslate(pi_t,ith_trans_est*-1);
            trans_error_est(pIdx,:)=trans_error_est(pIdx,:)+ith_trans_est;
            
            if idx~=ceil(size(rotSearch,3)/2)
                changeCount=changeCount+1;
            end
            fprintf('iter:%d p_idx:%d corr:%f idx:%d\n',i,pIdx,v,idx);
             
        end        
        G=reconstructObjWarper(p_est,R_est);
        tmp_p_est=takeProjectionWraper(G,R_est);
        error=findCorrelationError(p_est,tmp_p_est);  
        ithError(i+1,1)=error;
        timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
        fprintf('%s\titer:%d tprevCorr:%f\tCurCorr:%f \n',timestamp,i,ithError(i,1),error);
        fprintf(infoFH,'%s\titer:%d\tprevCorr:%f\tCurCorr:%f\tchangeCount:%d\n',timestamp,i,ithError(i,1),error,changeCount);                
        if(changeCount==0)
            break;
        end
        %% Checkpointing
        if (mod(i,5)==0)
            chk.R_est=R_est;
            chk.R_int=R_init;
            chk.confi=config;
            save(strcat(finalSavePath,'/result_chk.mat'),'chk');
        end
        %% DEBUG
        % rots_final_aligned = align_rots(R_est, config.rots_true);
        % G1=reconstructObjWarper(p,rots_final_aligned);
        % p_est1=takeProjectionWraper(G1,rots_final_aligned);
    end
    %%
    G_est=G;
    iteration=i;
    fclose(infoFH);
end

