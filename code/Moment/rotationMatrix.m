% Given rotation angles ax,ay,az
% Where 
% ax: rotation about x-axis
% ay: rotation about y-axis
% az: rotation about z-axis
% https://en.wikipedia.org/wiki/Rotation_matrix
% Clock-wise rotation
function [rotationZYX] = rotationMatrix(ax,ay,az)
    % Rx: Roation about X-axis
    % Ry: Roation about Y-axis
    % Rz: Roation about Z-axis
    Rx=[  1,     0,          0       ;...
          0,     cos(az),    -sin(az);...
          0,     sin(az),    cos(az) ;...
       ];
   
   %{
   Rx=[  cos(az),    -sin(az),  0;...
          sin(az),     cos(az),  0;...
          0,           0,        1;...
       ];
   
   %}
       
    Ry=[  cos(ay),     0,    sin(ay);...
          0,           1,    0      ;...
          -sin(ay),    0,    cos(ay);...
       ];

    Rz=[  cos(ax),    -sin(ax),  0;...
          sin(ax),     cos(ax),  0;...
          0,           0,        1;...
       ];
   
   % Final Rotation
   R=Rz*Ry*Rx;
   
   rotationZYX=R;
end

