% Paper: AN ALGORITHM FOR RECOVERING UNKNOWN PROJECTION ORIENTATIONS AND SHIFTS IN 3-D TOMOGRAPHY
% Eq (16). A part of that equation
% ∑ over β ≤ α & |β|=k
% α & β is the vector 1x3
% k is scalar

% Dev: Khursheed Ali
% Date: 16-09-2018
function [beta] = genSigmaRange(k,alpha)
    
    % 1. |β|=k
    b=gen3dOrderMoment(k);
    
    % 2. β ≤ α
    beta=b(b(:,1)<=alpha(1) & b(:,2)<=alpha(2) & b(:,3)<=alpha(3) ,:);
    
end

