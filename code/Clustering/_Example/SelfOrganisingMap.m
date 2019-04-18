%% TEST Example For Self Organising map

%% Dataset
% NOTE: Dataset should be between 0 and 1
% http://archive.ics.uci.edu/ml/datasets/iris
% Data Set Characteristics:   Multivariate
% Number of Instances: 150
% Attribute Characteristics: Real
% Number of Attributes: 4
% The data set contains 3 classes of 50 instances each, where each class refers to a type of iris plant. One class is linearly separable from the other 2; the latter are NOT linearly separable from each other
load iris_dataset
inputs = irisInputs;

%% SOM
dimension1 = 10;
dimension2 = 10;
net = selforgmap([dimension1 dimension2]);

%% TRAIN

[net,tr] = train(net,inputs);

%% TEST

outputs = net(inputs);
y=vec2ind(outputs)';
%%