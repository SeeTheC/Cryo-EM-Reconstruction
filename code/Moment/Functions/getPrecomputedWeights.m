% It will return the all precomputed moment weights till c
% Author: Khursheed
% Date: 5/05/2019 
function [preCalPartialWCell] = getPrecomputedWeights(c)
    %% Init
    k=[0:1:c];
    preCalPartialWCell=cell(c+1,1);
    %% Load
    parfor i=1:c+1
        preCalPartialWCell{i}=generateOnlyWeightMtx(k(i));  
    end
end

