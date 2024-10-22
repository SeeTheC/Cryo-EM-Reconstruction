% Ref: [Page 4] Structure and View Estimation for Tomographic Reconstruction
% Ref: [Page 7] Detecting Consistent Common Lines in Cryo-EM by Voting
function [C1,C2] = findC(phi)
    %% Formula: Triplet (taking three common line)
    % 1. cij=cji
    % 2. <cij,cik> = cos(phi_ij-phi_ik)
    % 3. C = [c1i,c1j,cij]^T
    %    C = [c12,c13,c23]^T
    % 4. M=C.C^T
    %    M23= [   1        <c12,c13>   <c21,c23>;
    %        <c13,c12>      1        <c31,c32>;
    %        <c23,c21>   <c32,c31>      1     ;  
    %
    %       ]
    %   Mij = c1 vector is same in all Mij, only new vector are c1i/ci1 and
    %   c1j/cj1
    % 5. C = UD^(1/2)
    
    %% 
    l=1;i=2;j=3;k=4;
    M1 = getM(phi,l,i,j);
    [U,D,V]=svds(M1);
    C1=U*(D^0.5);
    
    M2 = getM(phi,l,i,k);
    [U2,D2,V2]=svds(M2);
    C2=U2*(D2^0.5);
    
end

% Ref: [Page 4] Structure and View Estimation for Tomographic Reconstruction
function  [M]=getM(phi,l,i,j)
    M = [       1                 ,  cos(phi(l,i)-phi(l,j)) ,     cos(phi(i,l)-phi(i,j));
          cos(phi(l,j)-phi(l,i))  ,          1              ,     cos(phi(j,l)-phi(j,i));
          cos(phi(i,j)-phi(i,l))  ,  cos(phi(j,i)-phi(j,l)) ,           1;
        ];
end

