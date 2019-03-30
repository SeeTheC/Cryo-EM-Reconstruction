% Given two projections i and j it finds the phi_ij,phi_ji
function [phi_ij,phi_ji,val,correlationMTX] = findPhiBtwTwoProj(proj1,proj2)
    %% INT 
    angCount=size(proj1,1);
    n=size(proj1,2);
    phi_ij=0;phi_ij=0;
    %% Find
    %correlationMTX=[];    
    for i=1:angCount        
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
    phi_ij=(x-1)*angleIncOffset;
    phi_ji=(y-1)*angleIncOffset;
    phi_ji=phi_ji;
    %{
    
    %% NORMALIZED CORELATION
    p2=proj2;
    %mp2=mean(p2,2);
    %stdp2=std(p2')';
    %p2=bsxfun(@minus,p2,mp2);
    %p2=bsxfun(@rdivide,p2,stdp2);
    p2_norm=sqrt(sum(p2.^2,2));
    p2=bsxfun(@rdivide,p2,p2_norm);
    
    %correlationMTX=[];    
    for i=1:angCount
        b=proj1(i,:);
        %mb=mean(b);
        %stdb=std(b);
        %b=b-mb;
        %b=b./stdb;
        %a=bsxfun(@times,p2,b);        
        %a=sum(a,2)'./n;                
        b_norm=norm(b);
        b=b./b_norm;        
        a=bsxfun(@times,p2,b);        
        a=sum(a,2)';                
        nCorrMTX(i,:)=a;
    end
    
    [val,idx]=max(nCorrMTX(:));
    nx=mod(idx,angCount);    
    ny=floor(idx/angCount);
    if nx==0
        nx=angCount;
    else 
        ny=ny+1;
    end
    
    angleIncOffset=1;
    nphi_ij=(nx-1)*angleIncOffset;
    nphi_ji=(ny-1)*angleIncOffset;
    %}
end

