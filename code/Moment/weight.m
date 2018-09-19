% Paper: AN ALGORITHM FOR RECOVERING UNKNOWN PROJECTION ORIENTATIONS AND SHIFTS IN 3-D TOMOGRAPHY
% Eq (16) : a(Ri ; k, l ; α)

function [summation] = weight(Ri,k,l,alpha)
    % 1.All  sigma Order  ∑ over β ≤ α & |β|=
    [betas] = genSigmaRange(k,alpha);
    n=size(betas,1);
    summation=0;
    fprintf('k:%d l:%d aplha:[%d,%d,%d]\n',k,l,alpha(1),alpha(2),alpha(3));
    for i=1:n
        beta=betas(i,:);
        gamma=alpha-beta;
        kCb=combination(k,beta);lCg=combination(l,gamma);
        c=kCb*lCg;              
        r1=(Ri(1,1)^beta(1))*(Ri(2,1)^beta(2))*(Ri(3,1)^beta(3));
        r2=(Ri(1,2)^gamma(1))*(Ri(2,2)^gamma(2))*(Ri(3,2)^gamma(3));
        a=c*r1*r2;
        fprintf('beta:[%d,%d,%d] kCb:%f gamma:[%d,%d,%d] lCg:%f c:%f r1:%f r2:%f \n',beta(1),beta(2),beta(3),kCb,gamma(1),gamma(2),gamma(3),lCg,kCb*lCg,r1,r2);
      
        summation=summation+a;
    end    
end

