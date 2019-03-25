% Eq 17: A(k; Ψ)(l + 1, ok (α)) = a(R(Ψ); k − l, l; α).
% Param:
% momentOrder: single number say. 2
% angles : [ax,ay,az]; angel with x-axis,y-axis,z-axis repectively
% return:
% weights = [a(Ri,k,l,alpha) ], decending order i.e for momentOrder=2
% o/p: [a(Ri,2,0,[2,0,0]),a(Ri,2,0,[1,1,0]) ...]
% Dev: Khursheed Ali
% Date: 21-09-2018

function [AMtx] = weightMtx(momentOrder,angles,offset)    
    %% INIT
    TIGER_PROJECTION_YANGLE_FIX=-pi/2;    
    ax=angles(1);ay=angles(2);az=angles(3);    
    %Ri=rotationMatrix(ax,ay+TIGER_PROJECTION_YANGLE_FIX,az);
    %Ri=rotationMatrix(ax-pi/2,ay+pi,az+pi); % p1   
    %Ri=rotationMatrix(ax+pi/2+pi,ay-pi+pi/2,az-pi+pi/2); % p2
    Ri=rotationMatrix(ax+offset(1),ay+offset(2),az+offset(3));
    
    order2d=gen2dOrderMoment(momentOrder); 
    order3d=gen3dOrderMoment(momentOrder); 
    %% Finding weights
    AMtx=zeros(size(order2d,1),size(order3d,1));
    for i=1:size(order2d,1)
        k=order2d(i,1);l=order2d(i,2);
        %fprintf('->k:%d l:%d\n',k,l);
        for j=1:size(order3d,1)        
            AMtx(i,j)=weight(Ri,k,l,order3d(j,:));
            %fprintf('p:%d q:%d r:%d w:%f\n',order3d(j,1),order3d(j,2),order3d(j,3),AMtx(i,j));      
        end
    end
end

