% Given function "f" and "n", it returns the all moment such that k+l=2
% Return:
% moment: moments
% order : all the order such that k+l=n in  the same order as result in
% moment
% combined: [order, moment ]
function [moment,order,combined] = nthCentralMoment2D(f,n)
    % 1. Finding all n order moment such that k+l=n
    [order] = gen2dOrderMoment(n);
    cellOrder = mat2cell(order,ones(1,size(order,1)));
    
    %% 2. Moment calculation function k+l=n
    function [ moment_kl ] = perOrder_kl(kl)   
        k=kl{1}(1);l=kl{1}(2);
        %fprintf('k:%d l:%d:\n',k,l);
        moment_kl=centralMoment2D(f,k,l);
    end
    %% 3. Find All moments parallel 
    fprintf('Finding F(%d) moment..\n',n);        
    allMoments=arrayfun(@perOrder_kl,cellOrder);
    fprintf('Done.\n');
    %% 4. Result
    moment=allMoments;    
    combined=[order,moment];
    
end

