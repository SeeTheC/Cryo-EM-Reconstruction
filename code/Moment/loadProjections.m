% load the .mat extention files
function [projections] = loadProjections(rawProjPath,maxNumProj,downsample)
    %% Read files names
    fprintf('Loading Projections ....\n');
    files=getDirFilesName(rawProjPath,'mat');
    N=min(maxNumProj,size(files,2));
    projections=[];
    %% Load Files
    fprintf('Number of Projections:%d \n',N);
    for i=1:N
        f=files{i};
        fpath=strcat(rawProjPath,'/',f);
        p=load(fpath);
        projections(:,:,i)=imresize(p.img,1/downsample);
    end
    %%
    fprintf('Done.\n');
end

