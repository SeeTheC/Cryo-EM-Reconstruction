% Try Correlation norm each projection on P with Pi and finds the min
% Author: Khursheed Ali
% Date: 24th May 2019
function [transIdx,rotIdx,v] = findMaxCorrProjWithTrans(allProj,transPiCell)    
    %% INIT    
    N=size(allProj,3);
    %% Find min
     parfor i=1:N
        p=allProj(:,:,i);        
        corrVal(:,i)=arrayfun(@(x)corr2(x{1},p),transPiCell);        
     end
    [v,idx]=max(corrVal(:));
    [transIdx,rotIdx]=ind2sub(size(corrVal),idx);
    
end

