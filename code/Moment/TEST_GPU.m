function [result]=TEST_GPU(  )
    rng(1,'twister');
    A=rand(100,200)*1;
    IM=rand(200,1)*1;
    P=rand(100,1)*1;
    ADD=ones(1,100);
    h=23328000;
    %h=10000000;
    tic    
    cella = gpuArray([1:h]'); 
    A=gpuArray(A);
    P=gpuArray(P);
    IM=gpuArray(IM);
    ADD=gpuArray(ADD);
    fprintf('Done Inti. \n');
    %%
    %cellb=cella(1:10^3,:);
    h=size(A,1);
    w=size(A,2);
    %%
    fprintf('Starting\n');
    result=arrayfun(@perFun,cella);
    toc
    fprintf('Done\n');
    function [B] = perFun(idx)    
        %B=((P-A*IM));
        %B=sum(B(:)).*idx;
        %C=double(ADD.*P); 
        B=0;
        for i=1:h
            C=0;
            for j=1:w
                C=C+A(i,j)*IM(j);
            end
            C=P(i)-C;
            B=B+(C*C);
        end
        B=sqrt(B);
    end

end

