% Finding intial R_es using Commonline
% Author: Khursheed Ali

function [R_est] = getIntialRotMtx(phi)
        %% INIT
        radian=pi/180;
        %% FINDING R_est using Amit S. SVD Method
        S=ASINGER2011_GetS_step1(phi.*radian);
        [R_est,~,~] = ASINGER2011_GetR_step2(S,size(phi,1));   
        
        %% %% Verify PredR
        %R1=predR(:,:,1);
        %R2=predR(:,:,2);
        %R1*[cos(phi(1,2)*radian);sin(phi(1,2)*radian);0]
        %R2*[cos(phi(2,1)*radian);sin(phi(2,1)*radian);0]
end


