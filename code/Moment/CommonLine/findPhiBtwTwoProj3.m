function [phi_ij,phi_ji,val,corrMTX] = findPhiBtwTwoProj3(proj1,proj2)
  %% INT 
    angCount=size(proj1,1);
    n=size(proj1,2);
    phi_ij=0;phi_ij=0;
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
        corrMTX(i,:)=a;
    end
    
    [val,idx]=max(corrMTX(:));
    nx=mod(idx,angCount);    
    ny=floor(idx/angCount);
    if nx==0
        nx=angCount;
    else 
        ny=ny+1;
    end
    
    angleIncOffset=1;
    phi_ij=(nx-1)*angleIncOffset;
    phi_ji=(ny-1)*angleIncOffset;
end

