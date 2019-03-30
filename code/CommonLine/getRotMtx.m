% Return Rot matrix given two vectors
% Using the concept of qunatenion
% Ref: https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d
% Authour: Khursheed Ali.
% Date: 13/01/2019

function [rotMtx] = getRotMtx(V1,V2) 
    A=V1./norm(V1);B=V2./norm(V2);
    rotMtx = UU(FFi(A,B), GG(A,B));
end

function [mtx] = GG(A,B)                   
       mtx=[ dot(A,B) -norm(cross(A,B)) 0;
              norm(cross(A,B)) dot(A,B)  0;
              0              0           1
           ];
end

function [mtx] = FFi(A,B) 
    mtx= [ A (B-dot(A,B)*A)/norm(B-dot(A,B)*A) cross(B,A) ];
end
    
function [mtx]=UU(Fi,G) 
    mtx=Fi*G*inv(Fi);
end

