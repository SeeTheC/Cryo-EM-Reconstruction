% Author: Khursheed Ali
% Date: 6/05/2019
function saveProjections(projections,parDir,N,suffix)
    %% INIT
    N=min(size(projections,3),N);
    fDir=strcat(parDir,'/sample_',suffix);
    mkdir(fDir);
    %% save
    for i=1:N
        p=projections(:,:,i);
        minValue=min(p(:)); 
        p=p-minValue;
        maxVal=max(p(:));
        p=p./maxVal;
        fp=strcat(fDir,'/',num2str(i),'.jpg');
        imwrite(p,fp);
    end
end

