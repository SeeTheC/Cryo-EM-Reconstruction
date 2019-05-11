% Find the angles for which L2 error is less in the Search space
% Author:Khursheed Ali
% Date: 6/05/2019
function [val,idx,error] = findMomentL2ErrorAngFast(Pi,An,Im)
       %% Init
       val=inf;idx=-1;    
       %% Error
       N=size(Pi,1);
       rPi=gpuArray(repmat(Pi,[1,1,size(An,3)]));        
       P_est=pagefun(@mtimes,gpuArray(An),gpuArray(Im));  
       error=squeeze(sqrt(sum((rPi-P_est).^2,1)./N));  
       [val,idx]=min(error);        
       error=gather(error);
        %% Find min
        %parfor i=1:N            
        %    error(i)=corr(gather(P_est(:,:,i)),Pi);
        %end
        %[val,idx]=max(error);
end

