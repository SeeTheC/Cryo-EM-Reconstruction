% Finding commonline using 1D Projection method 
% Author: Khursheed Ali
function [phi,error] = getCommonline(projections,isGpu)     
        [proj1D] = get1DProjections(projections,isGpu);
        gproj1D=proj1D;
        if isGpu
            gproj1D=gpuArray(proj1D);
        end
        tic
        [phi,error] = getPhi(gproj1D);
        %phi=phi+1;
        phi(1:1+size(phi,2):end)=0;
        toc        
        fprintf('Done\n')
end

