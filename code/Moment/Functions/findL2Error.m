% Finds the L2 Error
% Author: Khursheed Ali

function [error] = findL2Error(trueProj,predProj)
    %% INIT  
    N=numel(trueProj);
    %%
    sqDiff=(trueProj-predProj).^2;
    error=sqrt( sum(sqDiff(:))/N);
end

