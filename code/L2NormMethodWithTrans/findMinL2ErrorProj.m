% Try L2 norm each projection on P with Pi and finds the min
% Author: Khursheed Ali
function [idx,v] = findMinL2ErrorProj(p,pi)    
    %% INIT
    idx=-1;
    n=size(pi,1)*size(pi,2);
    %% Find min
    sqDiff=abs(bsxfun(@minus,p,pi));
    s=sum(sqDiff,2);
    s=sum(s,1);
    s=squeeze(s);
    [v,idx]=min(s);
end

