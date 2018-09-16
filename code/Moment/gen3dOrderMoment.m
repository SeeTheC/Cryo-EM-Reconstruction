% Given n, generates all the k,l,m order such that k + l+ m =n in decending
% order
% Return : 3 col matrix 
% Example n=2; o.p (2,0,0),(1,1,0),(1,0,1),(0,1,1),(0,0,2)
function [order] = gen3dOrderMoment(n)
    order=[];
    for i=n:-1:0        
        order2nd=gen2dOrderMoment(n-i);
        h=size(order2nd,1);
        k=ones([h,1]).*i;
        order=[order;k,order2nd];
    end
end

