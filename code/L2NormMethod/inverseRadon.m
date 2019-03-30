% Given Projections and Rotation Matrix will reconstruct the obj
% Author: Khursheed Ali
function [obj3d] = inverseRadon(projections,R)
    %% Init
    noOfProj=size(projections,3);
    maxDim=max(size(projections,1),size(projections,2));
    emDim=[maxDim;maxDim;maxDim];
    predAngles=rotm2eul(R,'ZYX')'; 
    angles=predAngles;
    angles(2,:)=angles(2,:)+pi/2;
    
    p=projections;    
    %% Perform FBP 
    
    [obj3d]=reconstructObj(p(:,:,1:noOfProj),angles(:,1:noOfProj),emDim);
    
end

