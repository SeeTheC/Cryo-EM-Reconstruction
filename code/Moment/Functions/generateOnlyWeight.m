% Paper: AN ALGORITHM FOR RECOVERING UNKNOWN PROJECTION ORIENTATIONS AND SHIFTS IN 3-D TOMOGRAPHY
% Eq (16) : a(Ri ; k, l ; α) But NOT USING Ri
% NOTE: Used for Percomputation of weights. See "weight.m"
% Author: Khursheed
% Date: 5/05/2019 
function [W] = generateOnlyWeight(k,l,alpha)
    %% INIT    
    %%
    % 1.All  sigma Order  ∑ over β ≤ α & |β|=
    [betas] = genSigmaRange(k,alpha);
    n=size(betas,1);
    Coff=zeros(n,1);
    Beta=zeros(n,3);
    Gamma=zeros(n,3);    
    %fprintf('k:%d l:%d aplha:[%d,%d,%d]\n',k,l,alpha(1),alpha(2),alpha(3));
    for i=1:n
        beta=betas(i,:);
        gamma=alpha-beta;
        kCb=combination(k,beta);lCg=combination(l,gamma);
        c=kCb*lCg;                      
        Coff(i)=c; 
        Beta(i,:)=beta;
        Gamma(i,:)=gamma;
    end    
    %% Result
    W.KL=[k,l];
    W.Alpha=alpha;
    W.Coff=Coff;
    W.Beta=Beta;
    W.Gamma=Gamma;
end

