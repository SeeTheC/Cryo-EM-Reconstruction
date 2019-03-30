% Take projections give rot matrix
% NOTE: Use takeProjectionWraper instead of takeProjection if projections are
% to be used for finding common line;
% Author: Khursheed Ali
% Date: 29th March 2019
function [projections] = takeProjectionWraper(obj,rotMtx)
    %% Initial offset
    % NOTE: THIS CONFIG IF FOUND OUT BY ANALYSING ASPIRE AND TIRGE TOOLBOX
    angles=rotm2eul(rotMtx,'ZYX')';
    angles(2,:)=angles(2,:)+pi/2; % Adding correction offset
    %% Take Projection
    [projections] = takeProjections(obj,angles);
end

