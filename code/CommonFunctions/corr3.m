% Find 3D Correlation
% Author: Khursheed Ali
function [coff] = corr3(A,B)
    %% INIT
    Am=mean(A(:));
    Bm=mean(B(:));
    %% coff
    A1=A-Am;
    B1=B-Bm;
    C=A1.*B1;    
    A2=A1.^2;
    B2=B1.^2;
    n=sum(C(:));
    d=sqrt( sum(A2(:)) * sum(B2(:)) );
    coff=n/d;
    
end

