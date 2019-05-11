% Precompute the Eq16 sigma coffients 
% Dev: Khursheed Ali
% Date: 4-05-2019
function [coffCell] = getCoefficent(c,order2dCell,order3dCell)
    %% 1. INIT
    order2d=order2dCell;
    order3d=order3dCell;    
    N=c+1;
    %% 2. Find Coefficents
    for i=1:N
        
    end
end

function [AMtx] = coeff(order2d,order3d)    
    %% INIT    
    ax=angles(1);ay=angles(2);az=angles(3);    
    Ri=rotationMatrix(ax,ay,az);    
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

