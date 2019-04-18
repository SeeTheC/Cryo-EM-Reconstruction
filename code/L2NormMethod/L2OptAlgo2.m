% Aternating minizatation
% Author: Khursheed Ali

function [G_est,R_est,error,iteration] = L2OptAlgo2(projection,G_init,R_init,maxLoop,searchOffest,config)
    %% Config
    %trueObj=config.trueObj;  
    p=projection;    
    n=size(p,3);
    G=G_init;
    R_est=R_init;        
    finalSavePath=config.finalSavePath;  
    searchThershold=searchOffest; % x deg. means +/- x deg in x,y,z,axis    
   
    %G=trueObj; % DEBUG    
    %R_est=config.rots_true; %DEBUG
    
    %% INIT
    infoFP=strcat(finalSavePath,'/0_info.txt');
    infoFH=fopen(infoFP,'a+');    
    p_est=takeProjectionWraper(G,R_est);
    ferror=findCorrelationError(p,p_est);
    fprintf('Initial Error:%f\n',ferror);  
    fprintf(infoFH,'Initial Correlation:%f\n',ferror);     
    fprintf('Search offset:%f\n',searchOffest);
    fprintf(infoFH,'Search offset:%f\n',searchOffest);
    searchArea=getSearchSpace(searchThershold);
    %% Optimization
    timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
    fprintf('%s\tOptimization started \n',timestamp);
    ithError(1)=ferror;       
    for i=1:maxLoop        
        %parfor pIdx=1:n
        error=inf*-1;
        changeCount=0;
        for pIdx=1:n
            %fprintf(repmat('\b', 1, outPrintSize));
            %outPrintSize = fprintf('iter:%d p_idx:%d\n',i,pIdx);
            
            r=R_est(:,:,pIdx);            
            ang=rotm2eul(r);
            angSearch=bsxfun(@plus,searchArea,[ang(1) ang(2) ang(3)]);
            rotSearch=eul2rotm(angSearch);
            noOfRtx=size(rotSearch,3);
            tmp_R_est=R_est;            
            error_idx=-1;            
            tic
            for rindx=1:noOfRtx
                tmp_R_est(:,:,pIdx)=rotSearch(:,:,rindx);
                [tmp_G] = reconstructObjWarper(p,tmp_R_est);
                tmp_p_est=takeProjectionWraper(tmp_G,tmp_R_est);
                %tmp_p_est=takeProjectionWraper(G,tmp_R_est); % DEBUG
                tmp_error=findCorrelationError(p,tmp_p_est);
                %error_val(rindx)=tmp_error;                
                if tmp_error>error
                    error=tmp_error;
                    error_idx=rindx;
                end
                fprintf('iter:%d p_idx:%d r_idx:%d tcorr:%f fcorr:%f fidx:%d\n',i,pIdx,rindx,tmp_error,error,error_idx);                                                
            end   
            toc
            %[val,error_idx]=min(error_val);            
            if(error_idx~=-1)
                changeCount=changeCount+1;
                R_est(:,:,pIdx)=rotSearch(:,:,error_idx);   
            end
        end        
        G=reconstructObjWarper(p,R_est);
        p_est=takeProjectionWraper(G,R_est);
        ferror=findCorrelationError(p,p_est);  
        ithError(i+1,1)=ferror;
        timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');        
        %% DEBUG
        rots_final_aligned = align_rots(R_est, config.rots_true);
        Q1=reconstructObjWarper(p,rots_final_aligned);
        corr3derror=corr3(config.trueObj,Q1);
        %%
        fprintf('%s\titer:%d\tprevCorr:%f\tCurCorr:%f\tchangeCount:%d\tcorr3derror:%f\n',timestamp,i,ithError(i),ferror,changeCount,corr3derror);
        fprintf(infoFH,'%s\titer:%d\tprevCorr:%f\tCurCorr:%f\tchangeCount:%d\tcorr3derror:%f\n',timestamp,i,ithError(i),ferror,changeCount,corr3derror);
        
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
    end
    %%
    iteration=i;
    G_est=G;
    fclose(infoFH);
end

