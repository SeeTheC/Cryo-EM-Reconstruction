% Try Correlation norm each projection on P with Pi and finds the min
% Author: Khursheed Ali
function [idx,v] = findMaxCorrProj(p,pi)    
    %% INIT    
    N=size(p,3);
    %% Find min
     parfor i=1:N
        corrVal(i)=corr2(p(:,:,i),pi);
     end
    [v,idx]=max(corrVal);
end

