% Given n, generates all the k,l order such that k + l =n in decending
% order
% Return : 2 col matrix 
% Example n= 2; o.p (2,0),(1,1),(0,2)
function [order] = gen2dOrderMoment(n)
    k=[n:-1:0];
    l=[0:1:n];
    order=[k',l'];
end

