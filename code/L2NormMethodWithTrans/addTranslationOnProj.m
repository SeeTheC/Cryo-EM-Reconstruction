% Adds Translation error on projection
% Author: Khursheed Ali
% Date: 24th May 2019
function [projectionCell] = addTranslationOnProj(projection,searchAreaTrans)
    %% INIT   
    n=size(projection,3);
    projectionCell=cell(n,1);
    m=size(searchAreaTrans,1);
    %% Process    
    for i=1:n
        p=projection(:,:,i);
        parfor j=1:m
        %for j=1:m
            x=searchAreaTrans(j,1);
            y=searchAreaTrans(j,2);
            transPCell{j,1}=imtranslate(p,[x,y]);
        end
        projectionCell{i}=transPCell;
    end
end

