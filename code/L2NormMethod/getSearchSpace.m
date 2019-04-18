% Returns the angle search space for minization
% Author: Khursheed Ali
function [area] = getSearchSpace(thershold)
    %% INIT
    resolution=1;
    offset=[-thershold:resolution:thershold]';
    n=numel(offset);
    %% Create space
    % area = [a,b,c]
    b=repmat(offset,1,n)';
    b=b(:);        
    c=repmat(offset,n,1);    
    m=numel(c);    
    a=repmat(offset,1,m)';
    a=a(:);
    d=repmat([b,c],n,1);
    area=[a,d];  
end

