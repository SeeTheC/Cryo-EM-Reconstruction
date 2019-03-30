% PHI = [phi_ij]_nxn 
% phi_ij = angle of common line between two projection i and j with x-axis
% of local coordinate system of i.
% Ref: Structure and View Estimation for Tomographic Reconstruction: 
% A Bayesian Approach [Page 4]
%  
function [phi,error] = getPhi(proj1D)
    %% INIT
    maxPhi_ij=size(proj1D,1)/2;
    N = size(proj1D,3);    
    %N=10;
    uHalfphi=zeros(N,N);
    lHalfphi=zeros(N,N); 
    uValHalfphi=zeros(N,N);
    lValHalfphi=zeros(N,N); 
    %% Process
    fprintf('Calculating Phi, the common line angle ...\n');
    tic
    [normProj1D] = normalize1DProjection(proj1D);
    %p1D=proj1D;
    p1D=normProj1D;    
    for i=1:N
        p1=p1D(:,:,i);                
        p1=p1(1:maxPhi_ij,:);
        p1_4=permute(p1,[3 2 1]);
        %p1_4=p1;        
        for j=i+1:N 
            %tic
            %fprintf(' i:%d j:%d\n',i,j);
            p2=p1D(:,:,j);            
            %[phi_ij,phi_ji,val,~] = findPhiBtwTwoProj2(p1_4,p2);
            %[phi_ij,phi_ji,val,~] = findPhiBtwTwoProj3(p1_4,p2);
            [phi_ij,phi_ji,val,~] = findPhiBtwTwoProj4(p1_4,p2);
            phi_ij=gather(phi_ij);
            phi_ji=gather(phi_ji);
            
            
            % MAPPING WITH TRUE COMMONLINE OF ASPIRE TOOL
            % BY: KHURSHEED ALI. 17/3/2019
            if phi_ij<90
                nphi_ij=phi_ij+90;
                nphi_ji=mod(phi_ji+90,360);
            else
                nphi_ij=phi_ij-90;
                nphi_ji=mod(phi_ji-90,360);
            end
            
            uHalfphi(i,j)=nphi_ij;
            lHalfphi(j,i)=nphi_ji;
            uValHalfphi(i,j)=gather(val);
            lValHalfphi(j,i)=gather(val);
            %toc
        end
    end   
    phi=uHalfphi+lHalfphi;
    error=uValHalfphi+lValHalfphi;
    toc
    fprintf('Calculation Done.');    
end

