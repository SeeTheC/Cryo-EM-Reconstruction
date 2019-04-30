% Dev: Khursheed Ali
% Date: 22-04-2019
function [f_final,R_est,f_init,R_init] = findAngleByCoordinateDecent(config)
    %% Input
    projections=config.projections;
    momentOrder=config.momentOrder;
    maxIteration=config.maxIteration;
    searchThershold=config.searchOffest;
    noOfProj=size(projections,3);    
    f_final=[];
    R_est=[];
    radian=pi/180;
    %% INIT
    tic
    fprintf('Initializing i/p and intermediate variables. This may take few mins ...\n');
    %% Step 1: Finding Projection Moment
    [projectionsMoment] = getProjectionMoment(projections,momentOrder);
    
    %% Step 2: Finding Initial estimate of the Projections
    %[initalAngles] = getInitalAngleEstimate(projections);    
    [R_init,f_init] = getInitalAngleEstimate(projections,config);
    
    
    %% Step 3: Define Search Space
    fprintf('Step 3# Creating Angle Search Space');
    
    searchArea=getSearchSpace(searchThershold).*radian; 
    
    
    %% Step 4: Init Complete
    fprintf('Initializing Completed.\n');  
    toc;
    %% Coordinate Decent
    
    [R_final,Im_final,An_final,error,iteration,ithError]=coordinateDecent(projectionsMoment,R_init,searchArea,momentOrder,maxIteration,config);
        
end



