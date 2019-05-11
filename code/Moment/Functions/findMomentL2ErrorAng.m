% Find the angles for which L2 error is less in the Search space
% Author:Khursheed Ali
% Date: 6/05/2019
function [val,idx,error] = findMomentL2ErrorAng(Pi,bAiCell,Im_est)
            %norm(PnCell{pIdx}-(getAc(x,momentOrder)*Im_est))...            
             error=cellfun(@(x)(...                           
                           sqrt(sum((Pi-(getAc(x,momentOrder)*Im_est)).^2)/66)...
                         ),bAiCell,'UniformOutput',true);    
            [val,idx]=min(error);
end

