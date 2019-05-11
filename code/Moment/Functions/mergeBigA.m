% Merges the Cell Ac into One Big A matix
% Author: Khursheed Ali
% Date: 5/05/2019
function [An] = mergeBigA(bigA,momentOrder)
    %% INIT
    noOfProj=size(bigA,1);
    An=[];
    %% Merge
    for i=1:noOfProj
       % Eq 18        
       Ac=getAc(bigA{i},momentOrder);      
       An=vertcat(An,Ac);
    end
end

