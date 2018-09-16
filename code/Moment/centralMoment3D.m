% https://en.wikipedia.org/wiki/Image_moment

function [moment_klm] = centralMoment3D(f,k,l,m)
    %% Init   
    W=size(f,1);H=size(f,2);D=size(f,3);
    [Y,X] = meshgrid([1:H],[1:W],[1:D]);
    % Center of Mass : cx,cy
    cx=ceil(H/2); cy=ceil(W/2); cz=ceil(D/2);
    %% Cental Moment
    % Sigma.Sigma (x-cx)^k (y-cy)^l (z-cz)^m f(x,y);
    
    % 1. Finding: x-cx and y-cy;
    X=X-cx; Y=Y-cy; Z=Z-cz;
    
    % 2. Finding: (x-cx)^k.(y-cy)^l.(z-cz)^m
    X=X.^k;
    Y=Y.^l;
    Z=Z.^m;
    weight=(X.*Y).*Z;
    % 3. Finding: (x-cx)^k.(y-cy)^l.(z-cz)^m f(x,y)
    result=weight.*f;
    
    %4. Finding: Sigma.Sigma (x-cx)^k.(y-cy)^l.(z-cz)^m f(x,y);
    moment_klm=sum(result(:));
end

