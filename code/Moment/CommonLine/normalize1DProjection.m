function [normProj] = normalize1DProjection(proj)
     %% INT 
    n=size(proj,2);
    p=proj;
    %% Normalize
    p_norm=sqrt(sum(p.^2,2));
    p=bsxfun(@rdivide,p,p_norm);   
    normProj=p;    
end

