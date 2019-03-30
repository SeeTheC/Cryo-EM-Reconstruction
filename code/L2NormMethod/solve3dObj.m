% Reconsturct 3D object from its 2D Projections
%% 3D Reconstrution of using L2 Norm

%  (G,R_est)  = agmin  || Pi - Radon(G',R_est_i) || for all i=1...N
%   where Pi = ith Projection
%         R_est_i =  R_est of ith Projection
%         G = Reconstructed Object using intial estimate
% 
% Author : Khursheed Ali

function [G_final,f_final,inv_R_est,G_init,f_init,inv_R_init,clError] = solve3dObj(config)
    %% INIT
    projections=single(config.projections);
    rots_true=config.rots_true;
    angles_true=config.angles_true;
    %em_true=config.em_true;
    
    recontObj=[];
    isGpu=config.isGpu;
    radian=pi/180;
    
    G_final=[]; % Estimated Reconstruction
    f_final=[]; % Estimated Reconstruction With Golbal roation correction
    %% Finding Initial Estimate
        %% 1. Commonline
        fprintf('1. Commonline.\n');
        n_theta=360;        
        [phi,error] = getCommonline(projections,isGpu);        
        truePhiDeg = clmatrix_cheat(rots_true, n_theta);
        clError=comparecl( truePhiDeg, phi, n_theta, 1 );
        fprintf('Percentage of correct common lines: %f%%\n\n',clError*100);
        fprintf('Done.\n');
        %% 2. Finding R_est using Amit S. method of SVD.
        fprintf('2.Finding INTAIL R_est using Amit S. method of SVD. \n');
        S=ASINGER2011_GetS_step1(phi.*radian);
        [inv_R_init,~,~,~,~] = ASINGER2011_GetR_step2(S,size(phi,1));
        fprintf('Done.\n');
        %% 3. Reconst Intial G_ object
        fprintf('Reconst Intial G_ object.\n');
        [G_init] = inverseRadon(projections,inv_R_init);
        G_final=G_init;
        fprintf('Done.\n');
        %% 4. Conclulate Error For Intial R
        inv_rots_true=permute(rots_true,[2 1 3]);
        inv_rots_est=R_est;
        inv_rots_aligned = align_rots(inv_rots_est, inv_rots_true);
        [f_init] = inverseRadon(projections,inv_rots_aligned);
        %figure,imshow3D(f_init);
        fprintf('Done.\n');
    %% Apply L2 Norm Optimation using Alternate Minmization
        %% 1. Init
        G=G_init;
        inv_R_est=inv_R_init;
        R_est=permute(inv_R_est,[2 1 3]);
        ang_est=eul2rotm(R_est);
        
end

