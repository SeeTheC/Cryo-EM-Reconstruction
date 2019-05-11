% Given function "f" and "c", it returns the all moment starting from 0 to
% c
% Return:
% moment: moments
% Author: Khursheed Ali
function [Im] = allCentralMoment3D(f,c)
        %% Init        
        Im=[];
        %%
        for ni=0:c
            Mn=nthCentralMoment3D(f,ni);
            Im=[Im;Mn];
        end
end

