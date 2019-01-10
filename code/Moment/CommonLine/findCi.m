% Ref: Structure and View Estimation for Tomographic Reconstruction: 
% A Bayesian Approach [Page 4]
% Date: 8/1/19
% Author: Khursheed Ali
function [Ci] = findCi(phi,i)
    %% INIT
    Phi_i=phi(i,3:5);
    % removing the 0 value
    %Phi_i(i)=[];
    n=numel(Phi_i);
    radian=pi/180;
    Ci=[];
    %%
    tM1=repmat(Phi_i,n,1);
    tM2=tM1';
    tM=tM1-tM2;
    M=cos(tM.*radian);  
    [U,D,V]=svds(M,4);
end

