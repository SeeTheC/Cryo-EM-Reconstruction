% Finds the Correlation Error
% Author: Khursheed Ali

function [error,corrVal] = findCorrelationError(trueProj,predProj)
    %% INIT  
    N=size(trueProj,3);
    %%    
    parfor i=1:N
        corrVal(i)=corr2(trueProj(:,:,i),predProj(:,:,i));
    end
    error=mean(corrVal);
end

