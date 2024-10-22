% Creates the An using the search bigAi and returns 3D matrix
% Author: Khursheed Ali
% Date: 24/04/2019
function [sAn] = getSearchAn(An,bigAiCell,idx,AcH,momentOrder)
        %% Int
        n=size(bigAiCell,1);
        sAn=[];
        %% Assemble
        k=(idx-1)*AcH+1;
        for i=1:n
            tAn=An;
            Ac=getAc(bigAiCell{i},momentOrder);
            tAn(k:(k+AcH)-1,:)=Ac;
            sAn{i,1}=tAn;
        end
end

