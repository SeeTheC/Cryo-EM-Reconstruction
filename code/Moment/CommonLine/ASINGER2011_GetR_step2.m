% Paper: Three-Dimensional Structure Determination from Common Lines in Cryo-EM by
% Eigenvectors and Semidefinite Programming
% Page: 552/10
% Equation: 3.13
function [R,ZYZ,U,Sv,V] = ASINGER2011_GetR_step2(S,N)
    %% Theory
    % Ri = Ai=[ x1_i,x2_i,x3_i
    %           y1_i,y2_i,y3_i
    %           z1_i,z2_i,z3_i    
    %         ]
    % X= [x1_1,x1_2,.....x1_N,x2_1,x2_2.....x2_N]^T;
    % Y= [y1_1,y1_2,.....y1_N,y2_1,y2_2.....y2_N]^T;
    % Z= [z1_1,z1_2,.....z1_N,z2_1,z2_2.....z2_N]^T;   
    % 
    %% INIT
    refI=[1,0,0;
          0,1,0;
          0,0,-1;
         ];
    %% Finding SVD
    [U,Sv,V]=svds(S,3);
    %% Finding X,Y,Z
    X=U(:,1);Y=U(:,2);Z=U(:,3);
    Xt=[X(1:N),X(N+1:end)]; 
    Yt=[Y(1:N),Y(N+1:end)];
    Zt=[Z(1:N),Z(N+1:end)];
    %Changing dimension
    Xt=permute(Xt,[3 2 1]);
    Yt=permute(Yt,[3 2 1]);
    Zt=permute(Zt,[3 2 1]);
    
    % Merging X,Y,Z;
    A=[Xt;Yt;Zt];
    
    % finding Ai_3 using Cross product of Ai_1 x Ai_2
    Ai_3=cross(A(:,1,:),A(:,2,:));
    A=[A,Ai_3];
    R1=[];R2=[];R=[];
    
    for i=1:N
        a=A(:,:,i); 
        [u1,sr1,v1]=svd(a);
        r1=u1*v1';
        % Refelection - b
        %b(:,1)=refI*a(:,1);b(:,2)=refI*a(:,2);b(:,3)=cross(b(:,1),b(:,2));        
        %[u2,sr2,v2]=svd(b);        
        %r2=u2*v2';
        if det(r1)==-1
            fprintf('i:%d has det as -1',i);
        end
        R1(:,:,i)=r1;
        angles=rotm2eul(R1(:,:,i),'ZYZ');
        if angles(1)<0
            angles(1)=2*pi+angles(1);
        end
        if angles(2)<0
            angles(2)=2*pi+angles(2);
        end
        if angles(3)<0
            angles(3)=2*pi+angles(3);
        end        
        ZYZ(:,i)=angles';
    end
    %%
    R=R1;    
end

