% Eq 17: A(k; Ψ)(l + 1, ok (α)) = a(R(Ψ); k − l, l; α).
% Param:
% angles : [ax1,ax2...;ay1,ay2,...; az1,az2....]; 
% angel with x-axis,y-axis,z-axis repectively
% C: Finds all A(k; Ψ) for k: 0 -> c for MULTIPLE angle
% return:
% AMtx Cell Array, where each row cell represent A(k; Ψ) for k: 0 -> c for
% respective image i.e number of rows will same as Angles

% Dev: Khursheed Ali
% Date: 23-09-2018
function [BigAMtxCell] = weightMtxUptoCMultAng(angles,c)   
    %% INIT
    order2d=cell(c+1,1);
    order3d=cell(c+1,1);
    for i=1:c+1
        order2d(i,:)={gen2dOrderMoment(i-1)}; 
        order3d(i,:)={gen3dOrderMoment(i-1)}; 
    end
    %% 1. Per Angle
    function [AMtxCell] = perAngle(ax,ay,az)           
        %fprintf('ax:%d ay:%d az:%d\n',ax,ay,az);
        [AMtxCell] = weightMtxUptoCPerAng([ax,ay,az],c);        
    end
    %% 2. Process all Angle
    fprintf('Finding moment Ac for All Angles...\n',c);  
    BigAMtxCell=cell(0,1);
    N=size(angles,1);
    parfor i=1:N
        %fprintf('i:%d\n',i);
        ax=angles(i,1);ay=angles(i,2);az=angles(i,3);
        BigAMtxCell{i,1}= AcPerAng([ax,ay,az],c,order2d,order3d);
    end
    %BigAMtxCell=arrayfun(@perAngle,angles(:,1),angles(:,2),angles(:,3));    
    fprintf('Done.\n');
    
end

function [AMtxCell] = AcPerAng(angles,c,order2d,order3d)      
    %% 1. Finding k: 0 -> c
    k = [0:1:c]';    
    %% 2. Per A(k; Ψ) Method
    function [AMtx] = perA_kAngle(order)   
        momentOrder=order;
        %fprintf('momentOrder:%d\n',momentOrder);
        [AMtx] = A(angles,order2d{momentOrder+1},order3d{momentOrder+1});
    end
    %% 3. Calling All K parallel 
    %fprintf('Finding A(%d,Ri) moment..\n',c);        
    AMtxCell=arrayfun(@perA_kAngle,k,'UniformOutput', false);
    AMtxCell=AMtxCell';
    %fprintf('Done.\n');
end

function [AMtx] = A(angles,order2d,order3d)    
    %% INIT
    TIGER_PROJECTION_YANGLE_FIX=-pi/2;    
    ax=angles(1);ay=angles(2);az=angles(3);    
    Ri=rotationMatrix(ax,ay+TIGER_PROJECTION_YANGLE_FIX,az);    
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





