% Assembles the Projections moment into one vector
% Author: Khursheed Ali
function [Pn] = assembleProjMoment(projMoment,momentOrder)
    %% INIT
    noOfProj=size(projMoment,3);
    Pn=[];
    %% Pn    
    for i=1:noOfProj
        for j=1:momentOrder+1
            Pn=vertcat(Pn,projMoment{i}{j});
        end
    end       
end

