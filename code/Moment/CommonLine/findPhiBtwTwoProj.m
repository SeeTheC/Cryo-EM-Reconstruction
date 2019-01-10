% Given two projections i and j it finds the phi_ij,phi_ji
function [phi_ij,phi_ji,val,correlationMTX] = findPhiBtwTwoProj(proj1,proj2)
    %% INT 
    angCount=size(proj1,1);
    n=size(proj1,2);
    phi_ij=0;phi_ij=0;
    %% Find
    %correlationMTX=[];   
    parfor i=1:angCount
        a=bsxfun(@minus,proj2,proj1(i,:));
        a=abs(a);
        a=sum(a,2)'./n;
        correlationMTX(i,:)=a;
    end        
    %% Result
    [val,idx]=min(correlationMTX(:));
    x=mod(idx,angCount);    
    y=floor(idx/angCount);
    if x==0
        x=angCount;
    else 
        y=y+1;
    end
    
    angleIncOffset=1;
    phi_ij=x-angleIncOffset;
    phi_ji=y-angleIncOffset;
end

