%% TEST SCRIPT
clear;

%% Config
dataNum = 70;
datasetName=num2str(dataNum);
 datasetPath='~/git/Dataset/EM';
 if(dataNum==1003)
    emFile=strcat(datasetPath,'/EMD-1003','/map','/emd_1003.map'); 
    em = mapReader(emFile);
 end
 if(dataNum==5693) 
    emFile=strcat(datasetPath,'/EMD-5693','/map','/EMD-5693.map');
    em = mapReader(emFile);
 end
 if(dataNum==5689) 
    emFile=strcat(datasetPath,'/EMD-5689','/map','/EMD-5689.map');
    em = mapReader(emFile);
 end
 if(dataNum==5762) 
    emFile=strcat(datasetPath,'/EMD-5762','/map','/EMD-5762.map');
    em = mapReader(emFile);
 end 
 if(dataNum==2222) 
    emFile=strcat(datasetPath,'/EMD-2222','/map','/EMD-2222.map');
    em = mapReader(emFile);
 end 
 if(dataNum==1050) 
    emFile=strcat(datasetPath,'/EMD-1050','/map','/EMD-1050.map');
    em = mapReader(emFile);
 end 
 if(dataNum==70)
    root = aspire_root();
    file_name = fullfile(root, 'projections', 'simulation', 'maps', 'cleanrib.mat');
    em = load(file_name);
    em=em.volref;
 end
 em(em<0)=0;
 emDim=size(em)'; 
 fprintf('Dataset:%d Dim:%dx%dx%d\n',dataNum,emDim(1),emDim(2),emDim(3));
 %% Projection : EM
 fprintf('Taking Projection EM.\n');
 vol_true=em;
 n=300;
 rots_true = rand_rots(n);
 
 % Generate clean image by projecting volume along rotations.
ims_clean = cryo_project(vol_true, rots_true);

% `cryo_project` does not generate images compatible with the other functions in
% the package, so we need to switch the x and y axes.
ims_clean = permute(ims_clean, [2 1 3]);

projections=ims_clean;
rots=rots_true;
shifts=zeros(n,2);
fprintf('Done.\n');
%%
[gobalRotMat] = getGlobalRotTransformation(rots,invert_rots(est_inv_rots));
[newPredR,newZYZ] = transformRot(gobalRotMat,invert_rots(est_inv_rots));
newPredR=invert_rots(newPredR);
%% Cube
O(:,:,1)=[1,2,3;4,5,6;7,8,9];
O(:,:,2)=[10,11,12;13,14,15;16,17,18];
O(:,:,3)=[19,20,21;22,23,24;25,26,27];

vol_true=O;
%% angles
quat=[1,0,0,0;
      0,1,0,0;
      0,0,1,0;
      0,0,0,1;
     ];
 
quat=quat';
rots_true = q_to_rot(quat);

%%

%plane 1: YZ : [0,0,0]
p1=[0,0,0,0,0;
    0,O(1,:,1)+O(1,:,2)+O(1,:,3),0;
    0,O(2,:,1)+O(2,:,2)+O(2,:,3),0;
    0,O(3,:,1)+O(3,:,2)+O(3,:,3),0;
    0,0,0,0,0;]

%plane 2: XY : [0,180,0]
p2=[0,0,0,0,0;
    0,squeeze(O(1,1,:)+O(2,1,:)+O(3,1,:))',0;
    0,squeeze(O(1,2,:)+O(2,2,:)+O(3,2,:))',0;
    0,squeeze(O(1,3,:)+O(2,3,:)+O(3,3,:))',0;
    0,0,0,0,0;];

p2=p2'

%plane 3: ZX : [90,0,0]
p3=[0,0,0,0,0;
    0,squeeze(O(1,1,:)+O(1,2,:)+O(1,3,:))',0;
    0,squeeze(O(2,1,:)+O(2,2,:)+O(2,3,:))',0;
    0,squeeze(O(3,1,:)+O(3,2,:)+O(3,3,:))',0;
    0,0,0,0,0;
    ]

p4=[0,7,16,25,0;
    0,12,30,18,0;
    0,15,42,69,0;
    0,8,26,44,0;
    0,3,12,21,0;
    ]

p5= [  0,0,0,0,0;
       7,24,61,44,27;
       4,18,42,38,24;
       1,12,33,32,21;
       0,0,0,0,0;
    ]

%% ASPIRE
% Generate clean image by projecting volume along rotations.
ims_clean = cryo_project(vol_true, rots_true);
fprint('Done\n');

%%