% Paper: Three-Dimensional Structure Determination from Common Lines in Cryo-EM by
% Eigenvectors and Semidefinite Programming
% Page: 556/14
% Equation: 5.4 & 5.5
function [gobalRot] = getGlobalRotTransformation(trueR,predR)
    %% INIT
    N= size(predR,3);    
    %% Finding Q. Eq: 5.3
    Q=zeros(3,3);
    for i=1:N
        tRi=trueR(:,:,i);
        pRi=predR(:,:,i);
        Q=Q+(pRi*tRi');
    end
    Q=Q./N;
    %% Finding Global Rotation
    [U,S,V]=svds(Q,3);
    O=V*U';
    gobalRot=O;
end

