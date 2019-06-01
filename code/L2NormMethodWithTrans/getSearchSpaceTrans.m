% Author: Khursheed Ali
% Date: 24rd May 2019
function [searchAreaTrans] = getSearchSpaceTrans(searchThershold)
    %% Init
    inc=1;
    %% Procees
    [Y,X] =meshgrid([-searchThershold:inc:searchThershold]);
    searchAreaTrans=[Y(:),X(:)];    
end

