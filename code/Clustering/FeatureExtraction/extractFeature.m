% Extract feature form images using "extractionType"
% Author: Khursheed Ali
% Date: 6nd Mar 2019, 2:00 AM

function [featureDataset] = extractFeature(images,config)
    %% INIT
    extractionType=config.extractionType;
    %%
    fprintf('Extracting features from the image ...\n');  
    if extractionType== 0 
        % convert image to vector; 
        fprintf('Finding features : VECTOR METHOD\n');
        [featureDataset] = feature0_imgToVector(images,config);    
    elseif extractionType== 1
        % convert image to featurs using Auto encoder; 
        fprintf('Finding features : AutoEncoder METHOD\n');
        [featureDataset] = feature1_AutoEncoder(images,config);
    end 
    fprintf('Done.\n');
end

