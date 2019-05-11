% Given function "f" and "n", it returns the all moment such that k+l=n
% Return:
% moment: moments
% order : all the order such that k+l=n in  the same order as result in
% moment
% combined: [order, moment ]
% Author: Khursheed Ali
function [moment,order,combined] = nthCentralMoment3D(f,n)
    % 1. Finding all n order moment such that k+l=n
    [order] = gen3dOrderMoment(n);
    cellOrder = mat2cell(order,ones(1,size(order,1)));
    
    %% 2. Moment calculation function k+l=n
    function [ moment_klm ] = perOrder_kl(klm)   
        k=klm{1}(1);l=klm{1}(2);m=klm{1}(3);
        %fprintf('k:%d l:%d:\n',k,l);
        moment_klm=centralMoment3D(f,k,l,m);
    end
    %% 3. Find All moments parallel 
    %fprintf('Finding F(%d) moment..\n',n);        
    allMoments=arrayfun(@perOrder_kl,cellOrder);
    %fprintf('Done.\n');
    %% 4. Result
    moment=allMoments;    
    combined=[order,moment];
    
end