% Assembles the A to get Ac
% Eq: 19 pc (i) = Ac(Ψi ) mc
% Author: Khursheed Ali
% Date: 23/04/2019
function [Ac] = getAc(Ai,momentOrder)
    %% INIT    
    c=momentOrder;
    [W] = getAcWidth(c);
    %% Assemble Ac
    Ac=[];padLeftZero=0;padRightZero=W;
    for j=1:c+1
        A=Ai{j};
        padRightZero=padRightZero-size(A,2);
        A=padarray(A,[0 padLeftZero],0,'pre');
        A=padarray(A,[0 padRightZero],0,'post');
        padLeftZero=padLeftZero+size(Ai{j},2);
        Ac=vertcat(Ac,A);
    end
end

