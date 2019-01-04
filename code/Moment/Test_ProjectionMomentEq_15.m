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
%Object: 1
O1(:,:,1)=[1,2,3;4,5,6;7,8,9];
O1(:,:,2)=[1,2,3;4,5,6;7,8,9];
O1(:,:,3)=[1,2,3;4,5,6;7,8,9];

%Object: 2
O2=permute(O1,[3,2,1]);

O3(:,:,1)=[1,2,3;4,5,6;7,8,9];
O3(:,:,2)=[11,12,13;14,15,16;17,18,19];
O3(:,:,3)=[21,22,23;24,25,26;27,28,29];


obj1=single(O1);
obj3d=permute(obj1,[3,2,1]);
objSize=size(obj1)';

%% Take Projection
[geo,padding]=getProjGeometry(objSize)
obj=padarray(obj1,padding./2);
%potgeometry(geo,-pi); 

% Angles
x=[0,0,0,0,pi/2,pi,pi/3,pi+(pi/3)];
y=[0,-pi/2,pi/2 0,pi,pi,pi/3,pi/3+pi];
z=[0,0,pi/2,pi/2,0,pi,pi/6,pi-pi/6];
angles=[x;y;z];

% take projection
fprintf('Taking projection...\n');
tic
projections=Ax(obj,geo,angles,'interpolated');
%projections=Ax(obj,geo,angles);
toc
fprintf('Done\n');
% Plot Projections
fprintf('Ploting Projection...\n');
%plotProj(projections,angles,'Savegif','temp.gif')
fprintf('Done\n');
%% Verifying - Moment Eq15 
% p(k,l) (i) = m(k,l,0) (fRi ) =  ∑ |α|=k+l a(Ri ; k, l; α) mα,
% (2,0) & (2,1)
fprintf('-------------------------\n');
projIdx=2;
k=2;l=1;
f=projections(:,:,projIdx);
ax=angles(1,projIdx);ay=angles(2,projIdx);az=angles(3,projIdx);
% Eq15 : Left Side
Pkl=centralMoment2D(f,k,l);
%mkl0=centralMoment3D(obj3d,k,l,0);
%fprintf('P_kl:%f\t m_kl0:%f\n',Pkl,mkl0);

% Eq15 : Right Side
alpha=k+l;
Ri=rotationMatrix(ax,ay-pi/2,az);
%Ri=rotationMatrix(0,-pi/2,0);
order=gen3dOrderMoment(alpha);
rightSide=0;
for i=1:size(order,1)    
    w=weight(Ri,k,l,order(i,:));
    cm=centralMoment3D(obj,order(i,1),order(i,2),order(i,3));
    tmp=w*cm;
    fprintf('p:%d q:%d r:%d w:%f cm:%f\n',order(i,1),order(i,2),order(i,3),w,cm);    
    rightSide=rightSide+tmp;
end
fprintf('Pkl:%f\trightSide:%f\n',Pkl,rightSide);
%% Testing Eq 16 My Matrix 
fprintf('-------------------------\n');
projIdx=3;
momentOrder=2;
f=projections(:,:,projIdx);
ax=angles(1,projIdx);ay=angles(2,projIdx);az=angles(3,projIdx);
% Eq 16
Pn=nthCentralMoment2D(f,momentOrder);
AMtx=weightMtx(momentOrder,[ax,ay,az]);
Mn=nthCentralMoment3D(obj,momentOrder);
fprintf('Left Side Pn:\n');
disp(Pn);
fprintf('Right Side AMtx*Mn:\n');
disp(AMtx*Mn);
%% Bulk Projection
projectionsCell = num2cell(projections,[1 2]);
momentOrder=2;
AllPn=getProjectionMoment(projectionsCell,momentOrder);

%%  TEST: findAngleByCoordinateDecent
projectionsCell = squeeze( num2cell(projections,[1 2]) );
param.projectionCell=projectionsCell;
param.momentOrder=2;
param.maxIteration=1;
findAngleByCoordinateDecent(param);
