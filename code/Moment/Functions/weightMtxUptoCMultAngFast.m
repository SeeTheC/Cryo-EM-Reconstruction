% Eq 17: A(k; Ψ)(l + 1, ok (α)) = a(R(Ψ); k − l, l; α).
% Param:
% angles : [ax1,ax2...;ay1,ay2,...; az1,az2....]; 
% angel with x-axis,y-axis,z-axis repectively
% C: Finds all A(k; Ψ) for k: 0 -> c for MULTIPLE angle
% return:
% AMtx Cell Array, where each row cell represent A(k; Ψ) for k: 0 -> c for
% respective image i.e number of rows will same as Angles

% Dev: Khursheed Ali
% Date: 4-05-2019
function [bigAMtxCell,bigAn]  = weightMtxUptoCMultAngFast(angles,c,preCalPartialWCell)     
    %% 1. Process all Angle
    %fprintf('Finding moment Ac for All Angles...\n');  
    BigAMtxCell=cell(0,1);
    N=size(angles,1);
    parfor i=1:N
        %fprintf('i:%d\n',i);
        ax=angles(i,1);ay=angles(i,2);az=angles(i,3);
        [bigAMtxCell{i,1},Ac]= AcPerAng([ax,ay,az],c,preCalPartialWCell);
        bigAn(:,:,i)=Ac;
    end
    %BigAMtxCell=arrayfun(@perAngle,angles(:,1),angles(:,2),angles(:,3));    
    %fprintf('Done.\n');
    
end

function [AMtxCell,Ac] = AcPerAng(angle,c,preCalPartialWCell)      
    %% 1. Finding k: 0 -> c
    k = [0:1:c]';    
    %% 2. Per A(k; Ψ) Method
    function [AMtx] = perA_kAngle(order)   
        momentOrder=order;
        %fprintf('momentOrder:%d\n',momentOrder);
        [AMtx] = A(angle,preCalPartialWCell{momentOrder+1});
    end
    %% 3. Calling All K parallel 
    %fprintf('Finding A(%d,Ri) moment..\n',c);        
    %AMtxCell=arrayfun(@perA_kAngle,k,'UniformOutput', false);
    %AMtxCell=AMtxCell';
    %fprintf('Done.\n');
        
    % Assemble Ac    
    [W] = getAcWidth(c);    
    Ac=[];padLeftZero=0;padRightZero=W;
    for j=1:c+1
        Ai=A(angle,preCalPartialWCell{j});
        AMtxCell{1,j}=Ai;
        padRightZero=padRightZero-size(Ai,2);
        tA=padarray(Ai,[0 padLeftZero],0,'pre');
        tA=padarray(tA,[0 padRightZero],0,'post');
        padLeftZero=padLeftZero+size(Ai,2);        
        Ac=vertcat(Ac,tA);
    end
end


function [AMtx] = A(angles,weightCell)    
    %% INIT    
    ax=angles(1);ay=angles(2);az=angles(3);    
    Ri=rotationMatrix(ax,ay,az); 
    [row,col]=size(weightCell);
    %% Finding weights
    AMtx=zeros(row,col);
    for i=1:row       
        for j=1:col    
            W=weightCell{i,j};
            r1=Ri(:,1)';r2=Ri(:,2)';
            r1Pow=bsxfun(@power,r1,W.Beta);
            r2Pow=bsxfun(@power,r2,W.Gamma);
            a=prod(r1Pow,2);
            b=prod(r2Pow,2);
            c=W.Coff.*a.*b;
            AMtx(i,j)=sum(c);
            %fprintf('p:%d q:%d r:%d w:%f\n',order3d(j,1),order3d(j,2),order3d(j,3),AMtx(i,j));      
        end
    end
end


