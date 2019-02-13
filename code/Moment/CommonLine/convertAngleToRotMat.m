% Convert angles to ZYZ rotation matrix
function [rotMat] = convertAngleToRotMat(angles)
    rotMat=eul2rotm(angles,'ZYZ');
end

