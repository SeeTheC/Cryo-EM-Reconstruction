% Dev: Khursheed Ali
% Date: 23-09-2018
function [outputArg1,outputArg2] = findAngleByCoordinateDecent(param)
    %% Input
    projections=param.projectionCell;
    momentOrder=param.momentOrder;
    maxIteration=param.maxIteration;
    noOfProj=size(projections,1);    
    %% INIT
    tic
    fprintf('Initializing i/p and intermediate variables. This may take few mins ...\n');
    [initalAngles] = getInitalAngleEstimate(projections);
    [projectionsMoment] = getProjectionMoment(projections,momentOrder);
    searchSpace.angles=getSearchAngles(1);
    searchSpace.index=[1:size(searchSpace.angles,1)];
    searchSpace.weights=weightMtxUptoCMultAng(searchSpace.angles,momentOrder);    
    fprintf('Initializing Completed.\n');  
    toc;
    %% Coordinate Decent
    
    [predAngles,netError]=coordinateDecent(projectionsMoment,initalAngles,searchWeights,momentOrder,maxIteration);
        
end

function [predAngles,netError]=coordinateDecent(projectionsMoment,initalAngles,searchWeights,momentOrder,maxIteration)
     %% Proceess
     netError=0;
     predAngles=initalAngles;
     bigA=weightMtxUptoCMultAng(predAngles,momentOrder);
     for i=1:maxIteration
         fprintf('----------[Interation %d]------------.\n',i);
         %% Step 1: Find Object Moment (Im) Using Angles (A) and Pm 
         [Im] = findObjectMoment(projectionsMoment,bigA,momentOrder);
         %% Setp 2: Finding Angle Based on Im
         tic
         findAngle(projectionsMoment{1},bigA,Im,momentOrder,searchSpace);
         toc
     end
end


