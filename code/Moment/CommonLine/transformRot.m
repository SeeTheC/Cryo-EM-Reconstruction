% Given transformation matrix, it applies the transforamtion to all rot
% matrix
function [tRot,ZYZ] = transformRot(transformation,rot)
    %% INIT
    N=size(rot,3);
    %% Transform
    for i=1:N
        tRot(:,:,i)=transformation*rot(:,:,i);
        angles=rotm2eul(tRot(:,:,i),'ZYZ');
        %{
        if angles(1)<0
            angles(1)=2*pi+angles(1);
        end
        if angles(2)<0
            angles(2)=2*pi+angles(2);
        end
        if angles(3)<0
            angles(3)=2*pi+angles(3);
        end        
        
        %}
        ZYZ(:,i)=angles';
    end
end

