% https://en.wikipedia.org/wiki/Image_moment

function [moment_kl] = centralMoment2D(f,k,l)
    %% Init   
    W=size(f,1);H=size(f,2);
    [Y,X] = meshgrid([1:H],[1:W]);
    % Center of Mass : cx,cy
    cx=ceil(H/2); cy=ceil(W/2);
    %% Cental Moment
    % Sigma.Sigma (x-cx)^k (y-cy)^l f(x,y);
    
    % 1. Finding: x-cx and y-cy;
    X=X-cx; Y=Y-cy;
    
    % 2. Finding: (x-cx)^k.(y-cy)^l
    X=X.^k;
    Y=Y.^l;
    weight=X.*Y;
    % 3. Finding: (x-cx)^k (y-cy)^l f(x,y)
    result=weight.*f;
    
    %4. Finding: Sigma.Sigma (x-cx)^k (y-cy)^l f(x,y);
    moment_kl=sum(result(:));
end

