% Dev: Khursheed Ali
% Date: 23-09-2018
function [R_init,f_init] = getInitalAngleEstimate(projections,config)
    %% Init
    isGpu=config.isGpu;
    rots_true=config.rots_true;
    noOfProj=size(projections,3);    
    tmpCLPath=strcat(config.checkpointpath,'/phi_p',num2str(noOfProj),'.mat');
    infoFH=fopen(strcat(config.finalSavePath,'/0_info.txt'),'w+'); 
    radian=pi/180;
    %% Random 
    %% 1. Commonline
    fprintf('Step 2# 1. Finding Commonline...\n');
    if config.checkpointing && exist(tmpCLPath, 'file') == 2
        fprintf('Fast load: Loading it from temporary storage...\n'); 
        phi=load(tmpCLPath,'phi');
        phi=phi.phi;            
    else
        [phi,~] = getCommonline(projections,isGpu);                
        save(tmpCLPath,'phi','-v7.3');
    end 
    [truePhiDeg,~] = getCommonlineFrmRotMtx(rots_true); 
    clError=comparecl( truePhiDeg, phi, 360, 1 );
    fprintf('Step 2# Percentage of correct common lines: %f%%\n\n',clError*100);
    fprintf(infoFH,'Percentage of correct common lines: %f \n',clError*100);                
    fprintf('Step 2# Done.\n');
    %% 2. Finding R_est using Amit S. method of SVD.
    fprintf('Step 2# 2.Finding INTIAL R_est using Amit S. method of SVD. \n');
    S=ASINGER2011_GetS_step1(phi.*radian);
    [R_init,~,~,~,~] = ASINGER2011_GetR_step2(S,size(phi,1));
    fprintf('Step 2# Done.\n');
     %% 3. Conclulate Error For Intial R        
    rots_aligned = align_rots(R_init, rots_true);        
    %[gobalRotMat] = getGlobalRotTransformation(rots_true,R_init);
    %[~,~,rots_aligned] = transformRot(gobalRotMat,R_init);
    [f_init] = reconstructObjWarper(projections,rots_aligned);
    %figure,imshow3D(f_init);
    fprintf('Step 2# Done.\n');
    %% 4. Close Asssets
    fclose(infoFH);
end

