% PHI = [phi_ij]_nxn 
% phi_ij = angle of common line between two projection i and j with x-axis
% of local coordinate system of i.
% Ref: Structure and View Estimation for Tomographic Reconstruction: 
% A Bayesian Approach [Page 4]
% 
function [phi,error] = getPhiUsingFourierLines(projFourierLines,angResolution)
    N = size(projFourierLines,3);
    %N=1000; % TEMP. DEBUG
    maxPhi_ij=size(projFourierLines,1)/2;    
    uHalfphi=zeros(N,N);
    lHalfphi=zeros(N,N); 
    uValHalfphi=zeros(N,N);
    lValHalfphi=zeros(N,N); 
    %% Process
    fprintf('Calculating Phi, the common line angle ...\n');
    tic
    for i=1:N
        fprintf('Processing Proj %d/%d...\n',i,N);
        p1=projFourierLines(:,:,i);
        p1=p1(1:maxPhi_ij,:);        
        %p1=gpuArray(p1);
        p1_4=permute(p1,[3 2 1]);
        for j=i+1:N 
            %tic
            %fprintf(' i:%d j:%d\n',i,j);
            p2=projFourierLines(:,:,j);   
            %p2=gpuArray(p2);
            [phi_ij,phi_ji,val,~] = findPhiBtwTwoProjFourierDomain2(p1_4,p2,angResolution);
            uHalfphi(i,j)=gather(phi_ij);
            lHalfphi(j,i)=gather(phi_ji);
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

