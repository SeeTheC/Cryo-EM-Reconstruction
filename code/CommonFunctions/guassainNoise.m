% Generate IID guassain noise
function noise= guassainNoise(row,col,sigma)    
    %adding noise to an image
    % sd is 5% of Intensity range. 5*256=12.8
    %rng(0,'twister');
    mean = 0.0;    
    noise = sigma.*randn(row,col) + mean;    
    %j = imnoise(uint8(img1),'gaussian',0,sigma^2/255^2);
end