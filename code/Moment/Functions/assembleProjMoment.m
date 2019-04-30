% Assembles the Projections moment into one vector
% Author: Khursheed Ali
function [Pn,PnCell] = assembleProjMoment(projMoment,momentOrder)
    %% INIT
    noOfProj=size(projMoment,3);
    Pn=[];
    %% Pn    
    for i=1:noOfProj
        Pc=[];
        for j=1:momentOrder+1
            Pc=vertcat(Pc,projMoment{i}{j});           
        end
        Pn=vertcat(Pn,Pc);
        PnCell{i,1}=Pc;
    end       
end

