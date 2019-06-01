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
    transSearchOffset=config.transSearchOffset;
    tmpTransProjCellPath=strcat(config.checkpointpath,'/proj_cell_n',num2str(n),'_offset',num2str(transSearchOffset),'.mat');
    %% Init
    %R_est=config.rots_true; %DEBUG
    %G=trueObj; % DEBUG
                
    infoFP=strcat(finalSavePath,'/0_info.txt');
    infoFH=fopen(infoFP,'a+');    
    tmp_p_est=takeProjectionWraper(G,R_est);
    error=findCorrelationError(config.projections,tmp_p_est);    
    fprintf('Initial Correlation:%f\n',error); 
    fprintf(infoFH,'Initial Correlation:%f\n',error);     
    fprintf('Rotation Search offset:%f\n',searchOffest);
    fprintf(infoFH,'Rotation Search offset:%f\n',searchOffest);
    fprintf('Translation Search offset:%f\n',transSearchOffset);
    fprintf(infoFH,'Translation Search offset:%f\n',transSearchOffset);
    
    searchArea=getSearchSpace(searchThershold).*radian; 
    searchAreaTrans=getSearchSpaceTrans(transSearchOffset);
    
    
    outPrintSize=0;
    %%  Translation init
    fprintf('Initializating Proj in Translation search space... \n');
    if config.checkpointing && exist(tmpTransProjCellPath, 'file') == 1
        fprintf('Fast load: Loading it from temporary storage...\n'); 
        s=load(tmpTransProjCellPath,'projectionCell');
        projectionCell=s.projectionCell;            
     else
        % [projectionCell] = addTranslationOnProj(p_true,searchAreaTrans);                  
        % save(tmpTransProjCellPath,'projectionCell','-v7.3');
    end   
    fprintf('Done\n');
    %% Optimization
   
    timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
    fprintf('%s\tOptimization started \n',timestamp);
    fprintf(infoFH,'%s\tOptimization started \n',timestamp);
    ithError(1)=error;      
    trans_error_est=[];
    p_est=p_true;
    for i=1:maxLoop        
        %parfor pIdx=1:n
        outPrintSize=0;
        changeCount=0;
        [projectionCell] = addTranslationOnProj(p_est,searchAreaTrans);
        for pIdx=1:n
            %fprintf(repmat('\b', 1, outPrintSize));
            %outPrintSize = fprintf('iter:%d p_idx:%d\n',i,pIdx);
            
            r=R_est(:,:,pIdx);            
            ang=rotm2eul(r);
            angSearch=bsxfun(@plus,searchArea,[ang(1) ang(2) ang(3)]);
            rotSearch=eul2rotm(angSearch);
            pi_est=takeProjectionWraper(G,rotSearch);                        
            transPiCell=projectionCell{pIdx};
            % finding Rotation and Translation
            %[idx,v] = findMinL2ErrorProj(pi_est,p(:,:,pIdx));
            %[rotIdx,v] = findMaxCorrProj(pi_est,p_est(:,:,pIdx));
            %[rotIdx,v] = findMaxCorrProj(pi_est,transPiCell{1});
            
            %transIdx=1;
            [transIdx,rotIdx,v] = findMaxCorrProjWithTrans(pi_est,transPiCell);
            R_est(:,:,pIdx)=rotSearch(:,:,rotIdx);
            p_est(:,:,pIdx)=transPiCell{transIdx};
            trans_error_est(pIdx,:)=searchAreaTrans(transIdx,:);
            
            if rotIdx~=ceil(size(rotSearch,3)/2) && transIdx~= ceil(size(searchAreaTrans,3)/2)
                changeCount=changeCount+1;
            end
            fprintf('iter:%d p_idx:%d corr:%f rot_idx:%d trans_idx:%d\n',i,pIdx,v,rotIdx,transIdx);
             
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

