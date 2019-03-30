% Return the 1D randon of the 2D image
function [proj1D] = get1DProjections(projections,isGpu)
    %% INIT
    N= size(projections,3);    
    %N=10;% TEMP: DEBUG
    angles=[0:1:180-(1e-10)];
    if nargin>1 && isGpu
        angles=gpuArray(angles);     
        projections=gpuArray(projections);    
    end
    %% Process
    fprintf('Finding 1D prjections: %d ... \n',N);
    tic
    parfor i=1:N
        pi=projections(:,:,i);
        %pi=pi(2:end,:); % TEMP; DEBUG
        %pi=pi(:,2:end); % TEMP; DEBUG
        r=radon(pi,angles)';        
        proj1D(:,:,i)=gather(r);        
    end
    clear projections;
    proj1D=[proj1D;fliplr(proj1D)];     
    toc
    fprintf('Done.\n');
end

