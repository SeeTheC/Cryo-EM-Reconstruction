% Reconstruct obj using projections given rotation matrix
% NOTE: Use reconstructObjWarper instead of reconstructObj if projections are
% to be used for finding common line;
% Author: Khursheed Ali
% Date: 29th March 2019
function [objFBP] = reconstructObjWarper(projections,rotMtx,emDim)
    %% Initial offset
    % NOTE: THIS CONFIG IF FOUND OUT BY ANALYSING ASPIRE AND TIRGE TOOLBOX
    angles=rotm2eul(rotMtx,'ZYX')';
    angles(2,:)=angles(2,:)+pi/2; % Adding correction offset
    %% Reconstruct Object
    [objFBP] = reconstructObj(projections,angles,emDim);
end

