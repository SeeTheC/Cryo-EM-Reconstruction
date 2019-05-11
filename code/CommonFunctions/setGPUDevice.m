% Try to set free gpu device
% Author: Khursheed Ali
function setGPUDevice()
    %% INIT
    n=gpuDeviceCount();    
    %% Set GPU
    if n==0
        fprintf('******************************************************************************\n');
        fprintf('***ERROR: Cannot Init GPU Device. Please check hardware for any GPU device.***\n');
        fprintf('******************************************************************************\n');
    elseif n==1
        gpuDevice(1);
    else
        idx=1;
        minBusyMem=inf;
        for i=1:n
            g=gpuDevice(i);
            busyMem=(g.TotalMemory-g.AvailableMemory)/(1024*1024*1024); 
            if busyMem<minBusyMem 
                idx=i;
                minBusyMem=busyMem;                
            end
        end
        gpuDevice(idx);
    end
end

