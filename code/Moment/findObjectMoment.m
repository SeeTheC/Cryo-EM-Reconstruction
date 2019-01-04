% Paper: AN ALGORITHM FOR RECOVERING UNKNOWN PROJECTION ORIENTATIONS AND SHIFTS IN 3-D TOMOGRAPHY
% In Eq Pn= AIm, Find Im given Pn and A
% param:
% projMoment: cell of projection Qx1
% bigA: cell of Q x (order+1)
% Note: Q: number of projection
% Dev: Khursheed Ali
% Date: 23-09-2018
function [Im] = findObjectMoment(projMoment,bigA,momentOrder)
    %% Init
    noOfProj=size(projMoment,1);
    Pn=[];An=[];ImCell={};
    % Width of A = (1/6)(c + 1)(c + 2)(c + 3) − 3, object first moment is zero
    % Object first moment is NOT zero = (1/6)(c + 1)(c + 2)(c + 3)
    % c: moment order
    W=(momentOrder+1)*(momentOrder+2)*(momentOrder+3)*(1/6);
    %% Assemble Projection Moment
    for i=1:noOfProj
        for j=1:momentOrder+1
            Pn=vertcat(Pn,projMoment{i}{j});
        end
    end
   %% Assemble bigA  See Eq 18
   for i=1:noOfProj
       % Eq 18 
       Ac=[];padLeftZero=0;padRightZero=W;
       for j=1:momentOrder+1
            A=bigA{i}{j};
            padRightZero=padRightZero-size(A,2);
            A=padarray(A,[0 padLeftZero],0,'pre');
            A=padarray(A,[0 padRightZero],0,'post');
            padLeftZero=padLeftZero+size(bigA{i}{j},2);
            Ac=vertcat(Ac,A);
       end
       An=vertcat(An,Ac);
   end
   %% Finding IM
   Im=inv(An'*An)*An'*Pn;
end
