% Self Organising Map
% Author: Khursheed Ali
function [clusterIdx,centroid,net] = SOM(datapoint,config)
    %% INIT    
    datapoint=datapoint';
    centroid=[];
    clusterIdx=[];
    k=config.k;
    dim1=ceil(sqrt(k));
    dim2=dim1;    
    fprintf('No of Lables:%d\n',dim1*dim2);
    fprintf('Clustering: Self Organising Map');   
    %% Network
    coverSteps=100;
    radius=7;    
    net = selforgmap([dim1 dim2],coverSteps,radius,'hextop','linkdist');
    %% Train
    fprintf('Training SOM...\n')
    [net,tr] = train(net,datapoint);
    fprintf('Done.\n');
    %% TEST

    outputs = net(datapoint);
    clusterIdx=vec2ind(outputs)';
    
end

