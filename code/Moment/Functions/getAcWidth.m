% Calculates the  width of Ac matrix
% Refer Eq 18: 
% Author: Khursheed Ali
% Date: 23/04/2019
function [W] = getAcWidth(momentOrder)
     %% INIT    
    % Width of A = (1/6)(c + 1)(c + 2)(c + 3) − 3, object first moment is zero
    % Object first moment is NOT zero = (1/6)(c + 1)(c + 2)(c + 3)
    % c: moment order
    c=momentOrder;
    %% Width
    W=(c+1)*(c+2)*(c+3)*(1/6);   
end

