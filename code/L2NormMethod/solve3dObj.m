% Reconsturct 3D object from its 2D Projections
%% 3D Reconstrution of using L2 Norm

%  (G,R_est)  = agmin  || Pi - Radon(G',R_est_i) || for all i=1...N
%   where Pi = ith Projection
%         R_est_i =  R_est of ith Projection
%         G = Reconstructed Object using intial estimate
% 
% Author : Khursheed Ali

function [G_final,f_final,R_est,corr_error,G_init,f_init,R_init,clError,iteration] = solve3dObj(config)
    %% INIT
    projections=single(config.projections);
    noOfProj=size(projections,3);
    rots_true=config.rots_true;
    %em_true=config.em_true;
    
    isGpu=config.isGpu;
    radian=pi/180;       
    tmpCLPath=strcat(config.checkpointpath,'/phi_p',num2str(noOfProj),'.mat');
    G_final=[]; % Estimated Reconstruction
    f_final=[]; % Estimated Reconstruction With Golbal roation correction    
    infoFH=fopen(strcat(config.finalSavePath,'/0_info.txt'),'w+'); 
    %% Finding Initial Estimate
        %% 0. Write Config
        fprintf(infoFH,'No. of Projection: %d\n',noOfProj);
        %% 1. Commonline
        fprintf('1. Commonline.\n');
        if config.checkpointing && exist(tmpCLPath, 'file') == 2
            fprintf('Fast load: Loading it from temporary storage...\n'); 
            phi=load(tmpCLPath,'phi');
            phi=phi.phi;            
        else
            [phi,~] = getCommonline(projections,isGpu);                
            save(tmpCLPath,'phi','-v7.3');
        end     
        %truePhiDeg = clmatrix_cheat(rots_true, n_theta); %ASPIRE
        [truePhiDeg,~] = getCommonlineFrmRotMtx(rots_true); 
        clError=comparecl( truePhiDeg, phi, 360, 1 );
        fprintf('Percentage of correct common lines: %f%%\n\n',clError*100);
        fprintf(infoFH,'Percentage of correct common lines: %f \n',clError*100);                
        fprintf('Done.\n');
        %% 2. Finding R_est using Amit S. method of SVD.
        fprintf('2.Finding INTIAL R_est using Amit S. method of SVD. \n');
        S=ASINGER2011_GetS_step1(phi.*radian);
        [R_init,~,~,~,~] = ASINGER2011_GetR_step2(S,size(phi,1));
        fprintf('Done.\n');
        %% 3. Reconst Intial G_ object
        fprintf('Reconst Intial G_ object.\n');
        [G_init] = reconstructObjWarper(projections,R_init);
        %figure,imshow3D(G_init);
        fprintf('Done.\n');
        %% 4. Conclulate Error For Intial R        
        rots_aligned = align_rots(R_init, rots_true);        
        %[gobalRotMat] = getGlobalRotTransformation(rots_true,R_init);
        %[~,~,rots_aligned] = transformRot(gobalRotMat,R_init);
        [f_init] = reconstructObjWarper(projections,rots_aligned);
        %figure,imshow3D(f_init);
        fprintf('Done.\n');
        %% 5. Close Asssets
        fclose(infoFH);
    %% Apply L2 Norm Optimation using Alternate Minmization
       
        [G_final,R_est,corr_error,iteration] = L2OptAlgo1(projections,G_init,R_init,config.maxIteration,config.searchOffest,config);
        
        rots_final_aligned = align_rots(R_est, rots_true);                
        %[gobalRotMat] = getGlobalRotTransformation(rots_true,R_est);
        %[~,~,rots_final_aligned] = transformRot(gobalRotMat,R_est);
        [f_final] = reconstructObjWarper(projections,rots_final_aligned);
                
end

