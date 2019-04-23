% Generate Angles by uniform distribution in Radian. 
% param:
% incAngel : ax -> 0 to 360 with incAngel. Same for ay and az;
% If incAngel=1 then number of angles permutation will be returned
% 4665000x3
% Dev: Khursheed Ali
% Date: 23-09-2018
function [angles] = getSearchAngles(incAngel)
    %% INTI    
    range=360-1;        
    % (ax,ay,az) = (pi+ax,pi+ay,pi-az)
    
    %% Create All permutation fo angle in uniform distribution
    ax = [0:incAngel:179];
    ay = [0:incAngel:179];
    az = [0:incAngel:range];
    [aa,bb,cc] = ndgrid(ax,ay,az) ;
    angles = [cc(:) bb(:) aa(:)] ;
    %angles=gpuArray(angles);
end

