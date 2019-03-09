% Perform K-means clustering
% Author: Khursheed Ali
% Date: 6nd Mar 2019, 3:43 AM

function [clusterIdx,centroid] = KMeansClustering(datapoint,config)
    %% INIT
    k=config.k;
    clusterType=config.clusterType;
    
    %% clustering
    fprintf('Clusterning the data points ...\n');
    tic
    stream = RandStream('mlfg6331_64');  % Random number stream
    options = statset('UseParallel',1,'UseSubstreams',1,...
                       'Streams',stream);
                   
    [clusterIdx,centroid] = kmeans(datapoint,k,...
                                   'Options',options,...
                                   'MaxIter',config.maxIter,...
                                   'Distance','cosine',...,
                                   'Display','final',...                                   
                                   'Replicates',config.replicates);
               
    fprintf('Done\n');
    toc             
end

