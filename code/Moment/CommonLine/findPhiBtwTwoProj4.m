% Finds commonline using cosine distance
function [phi_ij,phi_ji,val,correlationMTX] = findPhiBtwTwoProj4(proj1,proj2)
    %% INT 
    angCount=size(proj2,1);
    n=size(proj2,2);
    phi_ij=0;phi_ij=0;
    p1=proj1;
    %% Find
    correlationMTX=[];
    p2=repmat(proj2,1,1,size(proj1,3));       
    a=bsxfun(@times,p2,p1);        
    a=sum(a,2);                        
    correlationMTX=permute(a,[3 1 2]);
    %% Result
    %correlationMTX=gather(correlationMTX);
    [val,idx]=max(correlationMTX(:));
    rows=size(correlationMTX,1);    
    x=mod(idx,rows);    
    y=floor(idx/rows);
    if x==0
        x=angCount;
    else 
        y=y+1;
    end
    
    angleIncOffset=1;
    phi_ij=(x-1)*angleIncOffset;
    phi_ji=(y-1)*angleIncOffset;
end

