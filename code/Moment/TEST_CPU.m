function [result]=TEST_CPU(  )
    rng(1,'twister');
    A=rand(100,200)*1;
    IM=rand(200,1)*1;
    P=rand(100,1)*1;
    h=23328000;
    %h=10000000;
    tic    
    cella = [1:h]';
    fprintf('Done Inti. \n'); 
    %%
    fprintf('Starting\n');
    result=arrayfun(@perFun,cella);
    toc
    fprintf('Done\n');
    function [B] = perFun(idx)    
        B=norm(P-A*IM); 
    end

end

