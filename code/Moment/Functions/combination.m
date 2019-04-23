% nC[b1,b2,b3] = 
%     n!
% --------
% b1!b2!b3!

% Dev: Khursheed Ali
% Date: 16-09-2018
function [result] = combination(n,beta)    
    k=numel(beta);        
    % simple method
    r=factorial(n);
    for i=1:k
        r=r/factorial(beta(i));
    end
    result=r;
    
end

