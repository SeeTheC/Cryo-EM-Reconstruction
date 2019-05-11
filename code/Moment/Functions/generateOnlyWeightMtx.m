% Eq 17: A(k; Ψ)(l + 1, ok (α)) = a(R(Ψ); k − l, l; α).
% Param:
% momentOrder: single number say. 2
% return:
% weightCell : Cells of the struct of weights
% NOTE: Used for Percomputation of weights. See "weightMtx.m"
% Author: Khursheed
% Date: 5/05/2019 

function [weightCell] = generateOnlyWeightMtx(momentOrder)    
    %% INIT    
    wpath='precomputed_moments_weights';
    if exist(wpath, 'dir') == 0
        mkdir('precomputed_moments_weights');    
    end
    fPath=strcat(wpath,'/momentorder_',num2str(momentOrder),'.mat');        
    %% Finding weights
    if exist(fPath, 'file') == 2
        s=load(fPath,'weightCell');
        weightCell=s.weightCell;
    else
        order2d=gen2dOrderMoment(momentOrder); 
        order3d=gen3dOrderMoment(momentOrder);
        weightCell=cell(size(order2d,1),size(order3d,1));
        for i=1:size(order2d,1)
            k=order2d(i,1);l=order2d(i,2);
            for j=1:size(order3d,1)        
                weightCell{i,j}=generateOnlyWeight(k,l,order3d(j,:));
            end
        end
        save(fPath,'weightCell','-v7.3');
    end
end

