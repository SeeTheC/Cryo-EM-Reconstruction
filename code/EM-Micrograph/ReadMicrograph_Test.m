%% EMD 3D Projection
addpath(genpath('~/git/Cryp-EM/code/lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification'));
%%
base='~/git/Dataset/EM/EM-10025/10025/data/14sep05c_averaged_196';
file= strcat(base,'/','14sep05c_00024sq_00003hl_00002es_c.mrc');
saveBP='sample_result';
saveFN='14sep05c_00024sq_00003hl_00002es_c';
%file= strcat(base,'/','14sep05c_00024sq_00003hl_00005es_c.mrc');
[img,s,mi,ma,av]=ReadMRC(file);
img=img-min(img(:));
micrograph=img/max(img(:));
imwrite(micrograph,strcat(saveBP,'/',saveFN,'_micrograph.png'));
fprintf('Done\n');
%%
%base='~/git/Dataset/EM/EM-10025/10025/data/14sep05c_raw_196';
%file= strcat(base,'/','14sep05c_00024sq_00003hl_00002es.frames.mrc');
%[micrograph,s,mi,ma,av]=ReadMRC(file);
%%
imshow(micrograph(1:500,1:500),[]);
%%
downsample=12;
x=[2265,3752,2610,2632,1324,6956,4383,465,2980,5235,2309,4992,4373,6611,6939,3636,657,5532,340,5754,4932,4601,6831,6926,5385,1518,2971,6684,5349,6114,867,3348,2337,1551,5488,1725,2574,4155,7143,2070,2020,2314,4779,3632,4965,5952,5559,3978,5418,3783,1463,2481,4036,328,2436,3049,5932,4758,5755,1980,6149,3670,6553,3861,3571,2239,6317,4514,3763,4067,1164,4638,1450,3807,674,1452,3220,235,3337,3786,6750,6790,1041,3660,2513,3388,4839,437,736,6992,4805,3611,6250,7103,2303,3283,3286,4433,553,5106,5031,3356,3647,3791,792,3221,3221,3603,2585,5270,3958,2060,6064,566,3172,2069,2245,2806,6504,3650,5179,3388,2395,5430,3747,2594,5188,5923,1564,1213,4980,3397,357,3171,2739,6300,671,3409,6959,6156,2615,6411,1289,1877,741,801,5659,1935,4138,4399,4783,1271,4178,5640,1072,2707,1722,2068,1085,5852,5952,6050,1667,2997,393,1488,5464,636,1805,5883,1294,5249,1544,4012,4546,3318,2090,3981,5881,5158,3504,1001,2729,6733,4935,1400,6118,2498,3052,1572,1067,2367,5728,4685,4227,5195,6055,3078,1263,4189,3439,1584,5684,2288,1528,3664,3096,6110,5151,4426,4461,2161,1350,2387,2172,1019,2498,7138,3948,1238,419,5377,5587,4186,2265,5126,3299,5098,4883,691,3076,1248,5291,773,4293,2936,5346,1785,4016,6500,2128,6655,1823,1732,4189,6229,2718,4376,2838,6277,4539,4279,3336,5843,3630,6662,826,6163,2902,1773,6508,5142,4880,518,6933,6693,6986,4645,3999,532,538,3037,4411,1925,3648,5441,929,2904,6916,2370,2711,2210,7050];
y=[5606,326,5799,4904,4988,4728,4539,6885,4551,6822,2419,764,2296,497,5154,5206,7302,5936,1084,6025,5198,1781,6282,4346,7051,3388,3241,4115,3958,4764,1316,2991,3600,4554,5188,250,2087,5187,5374,4051,7362,1934,5630,1067,3411,1343,340,3713,5518,4093,7234,3955,1932,5514,1688,2691,848,3375,3002,3845,5167,6055,2628,3887,3430,1097,3329,4841,1487,2441,3024,4305,445,553,4955,3010,7157,4305,4441,3585,5681,1632,7090,2878,6018,5830,3108,1802,3158,6772,5951,4891,5480,6051,4720,6261,2331,1934,266,3694,5597,841,2623,7096,5780,3641,1858,5424,3495,5682,4519,284,2661,5978,4760,6010,772,7317,5499,790,2956,3764,932,667,4676,3723,3476,3186,5551,3311,4056,5441,7186,1057,6647,1740,5570,5130,1848,6599,7095,4266,4647,607,1847,4318,3856,3067,4392,6894,2611,6089,424,2793,3628,5209,2486,7084,5867,2091,2878,1563,462,5565,4911,1050,3732,1215,7419,1140,2347,860,6920,5702,1063,3346,3517,1396,6229,1072,1303,4597,1693,775,4395,6490,6831,5210,6183,6340,5339,5005,2289,6778,1499,4764,3363,4201,3765,7048,2103,1680,5446,7376,2178,6620,1260,3935,6423,1591,635,2651,7012,7143,4465,3208,528,1986,3160,1572,1408,3296,3511,4736,5906,2655,6603,4242,4674,3457,3428,1015,4514,6736,5356,1958,1197,6624,1106,1663,1510,3884,4101,3615,2984,1117,2917,5669,4930,7329,5823,2483,1444,374,1945,1954,2663,6014,928,1328,5820,5905,1110,798,5789,4492,2482,2879,7167,2001,2938,1482,3491,6345,5817,2736,2110,2485,3126,6192,5463,1723,3814];
img=imresize(micrograph,1/downsample);
dwnX=round(x./downsample);
dwnY=round(y./downsample);
img=img-min(img(:));
dwnMicrograph=img/max(img(:));
imshow(dwnMicrograph,[]),impixelinfo;
imwrite(dwnMicrograph,strcat(saveBP,'/',saveFN,'_micrograph_downscale_12.png'));
%%

%%
img1=dwnMicrograph;
lineWidth=1;predictColor='magenta';
for i=1:numel(x)
    cx=dwnX(i);cy=dwnY(i);
    markSize=1;
    img1=insertMarker(img1,[cy,cx],'x','color',predictColor,'size',markSize);    
    for w=1:lineWidth
        img1=insertMarker(img1,[cy-w,cx],'x','color',predictColor,'size',markSize); 
        img1=insertMarker(img1,[cy,cx-w],'x','color',predictColor,'size',markSize);    
        img1=insertMarker(img1,[cy+w,cx],'x','color',predictColor,'size',markSize);    
        img1=insertMarker(img1,[cy,cx+w],'x','color',predictColor,'size',markSize);    
    end
end
imwrite(dwnMicrograph,strcat(saveBP,'/',saveFN,'_micrograph_downscale_12_center.png'));
fprintf('Done.\n');
figure,imshow(img1),impixelinfo;
%% Draw box: Downscale MG
%idx=206; Good
mg=img1;
boxSize=[18,18];
figure,imshow(mg),impixelinfo;
for i=1:numel(x)
    cx=dwnX(i);cy=dwnY(i);
    [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,boxSize);
    fprintf('x1:%d x2:%d y1:%d y2:%d\n',x1,x2,y1,y2);
    rectangle('Position',[y1,x1,boxSize(2),boxSize(1)],...
          'EdgeColor', 'r',...
          'LineWidth', 1,...
          'LineStyle','-');
end
%imwrite(dwnMicrograph,strcat(saveBP,'/',saveFN,'_micrograph_downscale_12_box.png'));
patch=dwnMicrograph(x1:x2,y1:y2);
figure,
imshow(patch,[]);  
%% Draw box: Fullscale MG
%idx=206; good one
idx=20;
mg=micrograph;
boxSize=[18,18];
boxSize=boxSize.*downsample;
figure,imshow(mg),impixelinfo;
for i=1:numel(x)
    cx=x(i);cy=y(i);
    [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,boxSize);
    fprintf('x1:%d x2:%d y1:%d y2:%d\n',x1,x2,y1,y2);
    rectangle('Position',[y1,x1,boxSize(2),boxSize(1)],...
          'EdgeColor', 'r',...
          'LineWidth', 1,...
          'LineStyle','-');
end

%% Patch: FUll scale
idx=206;
cx=x(idx);cy=y(idx);
boxSize=[18,18];
boxSize=boxSize.*downsample;
[x1,x2,y1,y2] = getPatchCoordinat(cx,cy,boxSize);
patch=micrograph(x1:x2,y1:y2);
figure,
rzPatch=imresize(patch,1/2);
rzPatch=rzPatch-min(rzPatch(:));
rzPatch=rzPatch/max(rzPatch(:));
imshow(rzPatch);
pause(2);
imwrite(rzPatch,strcat(saveBP,'/',saveFN,'_patch_downscale2.png'));
fprintf('Done\n');
%% Show single particle 
i=2;
tx=dwnX;ty=dwnY;
mg=dwnMicrograph;
[x1,x2,y1,y2]=getPatchCoordinat(tx(i),ty(i),[100,100]);
patch=mg(x1:x2,y1:y2);

figure,
imshow(patch,[]);
%% 
ds=4;
img=imresize(patch,1/ds);
figure,imshow(img,[]);


    