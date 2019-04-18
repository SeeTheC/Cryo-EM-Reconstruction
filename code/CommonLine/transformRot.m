% Given transformation matrix, it applies the transforamtion to all rot
% matrix
% Author: Khursheed Ali

function [ntRot,ZYX,tRot] = transformRot(transformation,rot)
    %% INIT
    N=size(rot,3);
    %% Transform
    for i=1:N
        tRot(:,:,i)=transformation*rot(:,:,i);
        angles=rotm2eul(tRot(:,:,i),'ZYX');
                
        if angles(3)<0
            angles(3)=-(pi+angles(3)); % Reconstruction FIX
        else
           angles(3)=(pi-angles(3)); % Reconstruction FIX
        end        
        
        %}
        ZYX(:,i)=angles';
    end
    ntRot=eul2rotm(ZYX'); % Reconstruction FIX
end

