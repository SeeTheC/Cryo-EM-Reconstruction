% Remove Noise using Wiener filter
% Author: Khursheed Ali
function [rProj] = rmvNoiseWithWiener(projections)
    %% INIT
    n=size(projections,3);
    %% Remove Noise
    parfor i=1:n
        rProj(:,:,i)=wiener2(projections(:,:,i),[5 5]);
    end
end

