% Given two projections i and j it finds the phi_ij,phi_ji
function [phi_ij,phi_ji,val,correlationMTX] = findPhiBtwTwoProj2(proj1,proj2)
    %% INT 
    angCount=size(proj2,1);
    n=size(proj2,2);
    phi_ij=0;phi_ij=0;
    %% Find
    correlationMTX=[];
    p3=repmat(proj2,1,1,size(proj1,3));
    %p4=permute(proj1,[3 2 1]);
    p4=proj1;
    p5=bsxfun(@minus,p3,p4);
    a=sum(abs(p5)./n,2);
    correlationMTX=permute(a,[3 1 2]);
    %% Result
    %correlationMTX=gather(correlationMTX);
    [val,idx]=min(correlationMTX(:));
    rows=size(correlationMTX,1);    
    x=mod(idx,rows);    
    y=floor(idx/rows);
    if x==0
        x=angCount;
    else 
        y=y+1;
    end
    
    angleIncOffset=0.5;
    phi_ij=(x-1)*angleIncOffset;
    phi_ji=(y-1)*angleIncOffset;
end

