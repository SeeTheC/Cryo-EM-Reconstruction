% Paper: AN ALGORITHM FOR RECOVERING UNKNOWN PROJECTION ORIENTATIONS AND SHIFTS IN 3-D TOMOGRAPHY
% Eq (15) : p(k,l) (i) = m(k,l,0) (fRi ) = |α|=k+l a(Ri ; k, l; α) mα

%% INIT TIGER
clear all;
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));
callPath=pwd;
cd('../../lib/CERN-TIGRE/MATLAB'); 
funInitTIGRE();
cd(callPath); 

%% Init Object:
O1(:,:,1)=[1,2,3;4,5,6;7,8,9];
O1(:,:,2)=[1,2,3;4,5,6;7,8,9];
O1(:,:,3)=[1,2,3;4,5,6;7,8,9];

obj=single(O1);
objSize=size(obj)';
%% Take Projection
geo=getProjGeometry(objSize)
%potgeometry(geo,-pi); 

% Angles
x=[0,0,0,0,pi/2,pi/4];
y=[0,pi/2,pi/2 0,pi/2,pi/4];
z=[0,0,pi/2,pi/2,0,pi/4];
angles=[x;y;z];

% take projection
fprintf('Taking projection...\n');
tic
projections=Ax(obj,geo,angles,'interpolated');
toc
fprintf('Done\n');
% Plot Projections
fprintf('Ploting Projection...\n');
plotProj(projections,angles,'Savegif','temp.gif')
fprintf('Done\n');
%% Verifying - Moment Eq15 
% p(k,l) (i) = m(k,l,0) (fRi ) =  ∑ |α|=k+l a(Ri ; k, l; α) mα,
% (2,0) & (2,1)

k=0,l=1;
f=projections(:,:,1);
ax=0;ay=0;az=0;
% Eq15 : Left Side
Pkl=centralMoment2D(f,k,l);

% Eq15 : Right Side
alpha=k+l;
Ri=rotationMatrix(ax,ay,az);
order=gen3dOrderMoment(alpha);
rightSide=0;
for i=1:size(order,1)    
    w=weight(Ri,k,l,order(i,:));
    cm=centralMoment3D(obj,order(i,1),order(i,2),order(i,3));
    tmp=w*cm;
    %fprintf('p:%d q:%d r:%d w:%f cm:%f\n',order(i,1),order(i,2),order(i,3),w,cm);    
    rightSide=rightSide+tmp;
end
fprintf('Pkl:%f rightSide:%f\n',Pkl,rightSide);


%%
%{
k=2,l=0
p:2 q:0 r:0 w:1.000000 cm:90.000000
p:1 q:1 r:0 w:0.000000 cm:0.000000
p:1 q:0 r:1 w:2.000000 cm:0.000000
p:0 q:2 r:0 w:0.000000 cm:90.000000
p:0 q:1 r:1 w:0.000000 cm:0.000000
p:0 q:0 r:2 w:2.000000 cm:90.000000
Pkl:270.292969 rightSide:270.000000
===========
k:2 l:0 aplha:[2,0,0]
beta:[2,0,0] kCb:1.000000 gamma:[0,0,0] lCg:1.000000 c:1.000000 r1:1.000000 r2:1.000000 
k:2 l:0 aplha:[1,1,0]
beta:[1,1,0] kCb:2.000000 gamma:[0,0,0] lCg:1.000000 c:2.000000 r1:0.000000 r2:1.000000 
k:2 l:0 aplha:[1,0,1]
beta:[1,0,1] kCb:2.000000 gamma:[0,0,0] lCg:1.000000 c:2.000000 r1:1.000000 r2:1.000000 
k:2 l:0 aplha:[0,2,0]
beta:[0,2,0] kCb:2.000000 gamma:[0,0,0] lCg:1.000000 c:2.000000 r1:0.000000 r2:1.000000 
k:2 l:0 aplha:[0,1,1]
beta:[0,1,1] kCb:2.000000 gamma:[0,0,0] lCg:1.000000 c:2.000000 r1:0.000000 r2:1.000000 
k:2 l:0 aplha:[0,0,2]
beta:[0,0,2] kCb:2.000000 gamma:[0,0,0] lCg:1.000000 c:2.000000 r1:1.000000 r2:1.000000 
Pkl:270.292969 rightSide:270.000000

---------------------------------------
k=0,l=2
p:2 q:0 r:0 w:0.000000 cm:90.000000
p:1 q:1 r:0 w:0.000000 cm:0.000000
p:1 q:0 r:1 w:0.000000 cm:0.000000
p:0 q:2 r:0 w:0.000000 cm:90.000000
p:0 q:1 r:1 w:0.000000 cm:0.000000
p:0 q:0 r:2 w:2.000000 cm:90.000000
Pkl:300.820312 rightSide:180.000000
==

k:0 l:2 aplha:[2,0,0]
beta:[0,0,0] kCb:1.000000 gamma:[2,0,0] lCg:1.000000 c:1.000000 r1:1.000000 r2:0.000000 
k:0 l:2 aplha:[1,1,0]
beta:[0,0,0] kCb:1.000000 gamma:[1,1,0] lCg:2.000000 c:2.000000 r1:1.000000 r2:0.000000 
k:0 l:2 aplha:[1,0,1]
beta:[0,0,0] kCb:1.000000 gamma:[1,0,1] lCg:2.000000 c:2.000000 r1:1.000000 r2:0.000000 
k:0 l:2 aplha:[0,2,0]
beta:[0,0,0] kCb:1.000000 gamma:[0,2,0] lCg:2.000000 c:2.000000 r1:1.000000 r2:0.000000 
k:0 l:2 aplha:[0,1,1]
beta:[0,0,0] kCb:1.000000 gamma:[0,1,1] lCg:2.000000 c:2.000000 r1:1.000000 r2:0.000000 
k:0 l:2 aplha:[0,0,2]
beta:[0,0,0] kCb:1.000000 gamma:[0,0,2] lCg:2.000000 c:2.000000 r1:1.000000 r2:1.000000


%}