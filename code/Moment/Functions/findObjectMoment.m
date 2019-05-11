% Paper: AN ALGORITHM FOR RECOVERING UNKNOWN PROJECTION ORIENTATIONS AND SHIFTS IN 3-D TOMOGRAPHY
% In Eq Pn= AIm, Find Im given Pn and A
% param:
% Pn : Merged Projection moment
% bigA: cell of Q x (order+1)
% Note: Q: number of projection
% Dev: Khursheed Ali
% Date: 23-09-2018
function [Im,An,AcH,AcW] = findObjectMoment(Pn,bigA,momentOrder,noOfProj)
    %% Init
    An=[];Ac=[];
    % Width of A = (1/6)(c + 1)(c + 2)(c + 3) − 3, object first moment is zero
    % Object first moment is NOT zero = (1/6)(c + 1)(c + 2)(c + 3)
    % c: moment order
    W=(momentOrder+1)*(momentOrder+2)*(momentOrder+3)*(1/6);    
   %% Assemble bigA  See Eq 18
   [An] = mergeBigA(bigA,momentOrder);
   %% Finding IM
   [AcH,AcW]=size(Ac);
   Im=inv(An'*An)*An'*Pn;
end
