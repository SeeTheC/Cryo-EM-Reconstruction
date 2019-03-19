function [S,phi] = ASINGER2011_GetS_TESTFun(trueRot)
    %% INIT
    %trueRot=permute(trueRot,[2 1 3]);
    N=size(trueRot,3);
    S=[];
    %% Process
    x = zeros(N,N);
    y = zeros(N,N);
    phi = zeros(N,N);
    for i=1:N
        Ri=trueRot(:,:,i); 
        Rit=Ri';
        for j=1+i:N         
            Rj=trueRot(:,:,j);
            tc=cross(Ri(:,3),Rj(:,3));
            tc(abs(tc)<10^-9)=0;%making near to zero a zero            
            tc=tc./norm(tc);
            cij=Rit*tc;
            cji=Rj'*tc;
            %cij=cij./norm(cij);
            if (i~=j)
                x(i,j)=cij(1);y(i,j)=cij(2);            
                phi(i,j)=(atan2(cij(2),cij(1)));
                
                x(j,i)=cji(1);y(j,i)=cji(2);            
                phi(j,i)=(atan2(cji(2),cji(1))); 
            end
        end
    end
    %% Assembling S
    S11= x.*x'; S12=x.*y';
    S21= y.*x'; S22=y.*y';
    
    % S11(1:1+N:end) = 0;S12(1:1+N:end) = 0;
    % S21(1:1+N:end) = 0;S22(1:1+N:end) = 0;
    
    S= [ S11,S12;
         S21,S22;
       ]; 
end

