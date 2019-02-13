% Paper: Three-Dimensional Structure Determination from Common Lines in Cryo-EM by
% Eigenvectors and Semidefinite Programming
% Page: 550/8

function [S] = ASINGER2011_GetS_step1(phi)
    %% THEORY
    %
    % cij=[xij,yij,0] = [cos(phi_ij),sin(phi_ij),0]
    % 
    % S11_ij = xij.xji  S12_ij = xij.yji
    % S21_ij = yij.xji  S22_ij = yij.yji
    %
    % S11_ii = S12_ij = S21_ii = S22_ii = 0
    %
    % S = [ S11  S12]
    %     [ S21  S22]
    %
    
    %% INIT
    N=size(phi,1);
    %radian=pi/180;
    %phi=phi.*radian;
    cosPhi=cos(phi);
    sinPhi=sin(phi);
    
    
    %% Process
    S11=cosPhi.*cosPhi';S12= cosPhi.*sinPhi';
    S21= sinPhi.*cosPhi';S22= sinPhi.*sinPhi';
    
    S11(1:1+N:end) = 0;S12(1:1+N:end) = 0;
    S21(1:1+N:end) = 0;S22(1:1+N:end) = 0;
    
    S= [ S11,S12;
         S21,S22;
       ]; 
    
end

