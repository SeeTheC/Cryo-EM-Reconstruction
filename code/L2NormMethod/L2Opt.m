function [G_est,inv_R_est] = L2Opt(projection,G_init,inv_R_init,maxLoop,obj_true)
    %% INIT
    p=projection;
    G=G_init;
    inv_R_est=inv_R_init;
    R_est=permute(inv_R_est,[2 1 3]);
    ang_est=eul2rotm(R_est);    
    error=inf;
    
    %% Optimization
    for i=1:maxLoop
    end
end

