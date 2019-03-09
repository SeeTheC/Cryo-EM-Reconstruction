% Convert angles to ZYZ rotation matrix
function [rotMat] = convertAngleToRotMat(angles)
    rotMat=eul2rotm(angles,'ZYZ');
    %angles(:,2)=angles(:,2)-pi/2;
    %rotMat=eul2rotm(angles,'ZYX');
end

