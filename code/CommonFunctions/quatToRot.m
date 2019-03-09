% https://in.mathworks.com/help/robotics/ref/quaternion.rotmat.html#d120e61230
% https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
% quaternion: unit quaternion
function [R] = quatToRot(quaternion)
    %% INIT
    a=quaternion(1);b=quaternion(2);c=quaternion(3);d=quaternion(4);
    %%
    R= [
        2*a^2-1+2*b^2,  2*b*c-2*a*d,    2*b*d+2*a*c;
        2*b*c+2*a*d,    2*a^2-1+2*c^2,  2*c*d-2*a*b;
        2*b*d-2*a*c,    2*c*d+2*a*b,    2*a^2-1+2*d^2;                
       ];
end

