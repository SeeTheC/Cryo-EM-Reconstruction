% Finding All moments for all Projections from 0 to momentOrder;
% Dev: Khursheed Ali
% Date: 23-09-2018
function [projMomentCell] = getProjectionMoment(projections,momentOrder)
    %% 1. Init
    noOfProj=size(projections,3);
    projections = num2cell(projections,[1 2]);
    k=[0:momentOrder]';
    %% 2. Per Projection
    function [Pc] = perProjection(proj)  
        f=proj{1};
        fcell=cell(numel(k),1);
        fcell(:)={f};
        Pc=arrayfun(@perMoment,fcell,k,'UniformOutput', false);       
    end
    %% 3. Per Moment
    function [Pn] = perMoment(proj,order)  
        f=proj{1};
        Pn=nthCentralMoment2D(f,order);
    end   
    %% 4. Calling For Projection
    fprintf('Finding Projection moment of order %d ..\n',momentOrder);        
    projMomentCell=arrayfun(@perProjection,projections,'UniformOutput', false);    
    fprintf('Done with find Projection moment.\n');    
end

