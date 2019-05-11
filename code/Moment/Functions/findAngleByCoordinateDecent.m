% Dev: Khursheed Ali
% Date: 22-04-2019
function [f_final,R_est,f_init,R_init,iteration] = findAngleByCoordinateDecent(config)
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
    
    %[R_est,Im_final,An_final,error,iteration,ithError]=coordinateDecent(projectionsMoment,R_init,searchArea,momentOrder,maxIteration,config);
    [R_est,Im_final,An_final,error,iteration,ithError]=coordinateDecentFast(projectionsMoment,R_init,searchArea,momentOrder,maxIteration,config);
        
    rots_final_aligned = align_rots(R_est, config.rots_true);                
    %[gobalRotMat] = getGlobalRotTransformation(rots_true,R_est);
    %[~,~,rots_final_aligned] = transformRot(gobalRotMat,R_est);
    [f_final] = reconstructObjWarper(projections,rots_final_aligned);    
end



