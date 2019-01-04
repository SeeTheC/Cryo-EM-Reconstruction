% Eq 17: A(k; Ψ)(l + 1, ok (α)) = a(R(Ψ); k − l, l; α).
% Param:
% angles : [ax,ay,az]; angel with x-axis,y-axis,z-axis repectively
% C: Finds all A(k; Ψ) for k: 0 -> c
% return:
% AMtxC

% Dev: Khursheed Ali
% Date: 21-09-2018
function [AMtxCell] = weightMtxUptoCPerAng(angles,c)      
    %% 1. Finding k: 0 -> c
    k = [0:1:c]';    
    %% 2. Per A(k; Ψ) Method
    function [AMtx] = perA_kAngle(order)   
        momentOrder=order;
        %fprintf('momentOrder:%d\n',momentOrder);
        [AMtx] = weightMtx(momentOrder,angles);
    end
    %% 3. Calling All K parallel 
    %fprintf('Finding A(%d,Ri) moment..\n',c);        
    AMtxCell=arrayfun(@perA_kAngle,k,'UniformOutput', false);
    AMtxCell=AMtxCell';
    %fprintf('Done.\n');
end

