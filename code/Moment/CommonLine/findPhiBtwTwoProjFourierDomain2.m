% Given two projections i and j it finds the phi_ij,phi_ji in fouier Domain
function [phi_ij,phi_ji,error,correlationMTX] = findPhiBtwTwoProjFourierDomain2(projLine1,projLine2,angResolution)
    %% INT 
    angCount=size(projLine2,1);
    n=size(projLine2,2);
    phi_ij=0;phi_ij=0;
    %% Find
    correlationMTX=[];
    p3=repmat(projLine2,1,1,size(projLine1,3));
    %p4=permute(proj1,[3 2 1]);
    p4=projLine1;
    p3=bsxfun(@minus,p3,p4);
    p3=sqrt(sum(p3.^2,2)./n);
    correlationMTX=permute(p3,[3 1 2]);
    %% Result
    %correlationMTX=gather(correlationMTX);
    correlationMTX=abs(correlationMTX);
    [error,idx]=min(correlationMTX(:));
    rows=size(correlationMTX,1);    
    x=mod(idx,rows);    
    y=floor(idx/rows);
    if x==0
        x=angCount;
    else 
        y=y+1;
    end    
    phi_ij=(x-1)*angResolution;
    phi_ji=(y-1)*angResolution;
end

