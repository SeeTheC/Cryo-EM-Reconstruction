% Optimize angles using coordinate descent
% Param:
% projMoment: cell of projection Qx1
% Author: Khursheed Ali

function [R_final,Im_final,An_final,error,iteration,ithError]=coordinateDecent(projMoment,R_init,searchArea,momentOrder,maxIteration,config)
     
    %% Init     
     finalSavePath=config.finalSavePath;
     noOfProj=size(projMoment,3);
     [Pn,PnCell] = assembleProjMoment(projMoment,momentOrder);
     infoFP=strcat(finalSavePath,'/0_info.txt');
     infoFH=fopen(infoFP,'a+');    
    
     %% Setp 1: Find AO
     angels_int=rotm2eul(R_init);
     bigA=weightMtxUptoCMultAng(angels_int,momentOrder);   

     %% Step 2: Find Object Moment (Im) Using Angles (A) and Pm 
     [Im_init,An_int,AcH,AcW] = findObjectMoment(Pn,bigA,momentOrder,noOfProj);

     %% Setp 3: Finding Intial Error
     error=norm(Pn-An_int*Im_init);  
     ithError(1,1)=error;
     %fprintf('Search offset:%f\n',searchOffest);
     %fprintf(infoFH,'Search offset:%f\n',searchOffest);
     fprintf('Initial L2Error:%f\n',error); 
     
     %% Optimization
     timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
     fprintf('%s\tOptimization started \n',timestamp);
     fprintf(infoFH,'%s\tOptimization started \n',timestamp);    
     Im_est=Im_init;
     An=An_int;
     R_est=R_init;         
    for i=1:maxIteration
         fprintf('----------[Interation %d]------------.\n',i);  
         changeCount=0;
         %parfor pIdx=1:1 %noOfProj
         for pIdx=1:noOfProj
            r=R_est(:,:,pIdx);            
            ang=rotm2eul(r);
            angSearch=bsxfun(@plus,searchArea,[ang(1) ang(2) ang(3)]);
            AiCell=weightMtxUptoCMultAng(angSearch,momentOrder);   
            %[sAn] = getSearchAn(An,AiCell,pIdx,AcH,momentOrder);            
            error=cellfun(@(x)(... 
                          norm(PnCell{pIdx}-(getAc(x,momentOrder)*Im_est))...
                          ),AiCell,'UniformOutput',true);                    
            [v,idx]=min(error);
            R_est(:,:,pIdx)=eul2rotm(angSearch(idx,:));
            if idx~=ceil(size(angSearch,1)/2)
                changeCount=changeCount+1;
            end
            fprintf('iter:%d p_idx:%d l2error:%f idx:%d\n',i,pIdx,v,idx);
         end
        angels_est=rotm2eul(R_est);
        bigA_est=weightMtxUptoCMultAng(angels_est,momentOrder);   
        [Im_est,An,~] = findObjectMoment(Pn,bigA_est,momentOrder,noOfProj);
        error=norm(Pn-An*Im_est);  
        ithError(i+1,1)=error;
        timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
        fprintf('%s\titer:%d tprevCorr:%f\tCurCorr:%f\tchangeCount:%d\n',timestamp,i,ithError(i,1),error,changeCount);
        fprintf(infoFH,'%s\titer:%d\tprevCorr:%f\tCurCorr:%f\tchangeCount:%d\n',timestamp,i,ithError(i,1),error,changeCount);                
        if(changeCount==0)
            break;
        end 
        %% DEBUG
        % rots_final_aligned = align_rots(R_est, config.rots_true);
        % G1=reconstructObjWarper(config.projections,rots_final_aligned);
        % figure,imshow3D(G1)
    end
     %% Result
    Im_final=Im_est;
    An_final=An;
    R_final=R_est;
    iteration=i; 
    fclose(infoFH);    
end
