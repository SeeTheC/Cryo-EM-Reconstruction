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
addpath(genpath('../../lib/aspire-v0.14-0'));
%% Init Object:
%Object: 1
O1(:,:,1)=[1,2,3;4,5,6;7,8,9];
O1(:,:,2)=[1,2,3;4,5,6;7,8,9];
O1(:,:,3)=[1,2,3;4,5,6;7,8,9];

%Object: 2
O2=permute(O1,[3,2,1]);

O3(:,:,1)=[1,2,3;4,5,6;7,8,9];
O3(:,:,2)=[10,11,12;13,14,15;16,17,18];
O3(:,:,3)=[19,20,21;22,23,24;25,26,27];

obj1=single(O3);
objSize=size(obj1)';

%% Take Projection


% Angles
%x=[0,0,0,0,pi/2,pi,pi/3,pi+(pi/3)];
%y=[0,-pi/2,pi/2 0,pi,pi,pi/3,pi/3+pi];
%z=[0,0,pi/2,pi/2,0,pi,pi/6,pi-pi/6];
%angles=[x;y;z];
%{
angles= [ 0,        0,      0;
          pi/2,     0,      0;
          0,        pi/2,   0;
          0,        0,      pi/2;          
          -pi/2,     0,      0;
          0,        -pi/2,   0;
          0,        0,      -pi/2;
          -pi/2-pi,     0,      0;
          0,        -pi/2-pi,   0;
          0,        0,      -pi/2-pi;          
          pi,       0,      0;
          0,        pi,     0;
          0,        0,      pi;
          pi/2,     pi/2,   0;
          pi/2,     0,      pi/2;
          0,        pi/2,   pi/2;          
          pi/4,     pi/4,   pi/4;
          0,        pi/4,   pi/4;
    ];

%}

angles= [ 0,        0,      0;
         
          pi/2,     0,      0;
          0,        pi/2,   0;
          0,        0,      pi/2;
          pi/2,     pi/2,   0;
          pi/2,     0,      pi/2;
          0,        pi/2,   pi/2;          
          pi/2,     pi/2,   pi/2;
          
          pi,       0,      0;
          0,        pi,     0;
          0,        0,      pi;
          pi,       pi,     0;
          pi,       0,      pi;
          0,        pi,     pi;          
          pi,       pi,     pi;
          
          3*pi/2,   0,      0;
          0,        3*pi/2, 0;
          0,        0,      3*pi/2;
          3*pi/2,   3*pi/2, 0;
          3*pi/2,   0,      3*pi/2;
          0,        3*pi/2, 3*pi/2;          
          3*pi/2,   3*pi/2, 3*pi/2;
          
          pi/4,     0,      0;
          pi/4,     pi/4,      0;
          0,        pi/4,   pi/4;
          pi/4,     pi/4,   pi/4;
          pi/3,     pi/3,   pi/4;
          
    ];

angles=angles';


%% Take projection
[geo,padding]=getProjGeometry(objSize);
obj=padarray(obj1,padding./2);
%potgeometry(geo,-pi); 

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
%% 
ang=angles';
%ang(:,1)=ang(:,1);
%ang(:,2)=ang(:,2)-pi/2;
%ang(:,3)=ang(:,3)+pi/2;



% take projection
fprintf('Taking projection...\n');
tic

to=O3;
to = permute(O3,[3 2 1]);

% coverting
 
angT=angles';
angT=fliplr(angT)';

rotMtxZYZ=eul2rotm(angT','ZYX');
angZYX=rotm2eul(rotMtxZYZ,'ZYZ')';
rots_true=eul2rotm(angles');

aPro = cryo_project(single(to), rots_true);  
%aPro = permute(aPro, [2 1 3]);

toc
fprintf('Done\n');
% Plot Projections
%% Verifying - Moment Eq15 
% p(k,l) (i) = m(k,l,0) (fRi ) =  ∑ |α|=k+l a(Ri ; k, l; α) mα,
% (2,0) & (2,1)
fprintf('-------------------------\n');
projIdx=3;
k=0;l=3;
f=projections(:,:,projIdx);
ax=angles(1,projIdx);ay=angles(2,projIdx);az=angles(3,projIdx);
% Eq15 : Left Side
Pkl=centralMoment2D(f,k,l);
%mkl0=centralMoment3D(obj3d,k,l,0);
%fprintf('P_kl:%f\t m_kl0:%f\n',Pkl,mkl0);

% Eq15 : Right Side
alpha=k+l;
Ri=rotationMatrix(ax,ay-pi/2,az);
%Ri=eul2rotm([ax,ay+pi/2,az+pi/2],'ZYZ');

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
%%
%% TEST:FINDING CORRECT ORIENTATION
offset=[0,pi/2,pi,3*pi/2,-2*pi,-pi/2,-pi,-3*pi/2];
n=numel(offset);
projIdx=1;
momentOrder=3;
minError=Inf;
fprintf('Trying to find offset..\n');
for projIdx=1:3
    ans=[]; 
    minError=Inf;
for i=1:n
    for j=1:n
        for k=1:n
            f=projections(:,:,projIdx);
            ax=angles(1,projIdx);ay=angles(2,projIdx);az=angles(3,projIdx);
            % Eq 16
            Pn_true=nthCentralMoment2D(f,momentOrder);
            AMtx=weightMtx(momentOrder,[ax,ay,az],[offset(i),offset(j),offset(k)]);
            Mn=nthCentralMoment3D(obj,momentOrder);
            Pn_est= AMtx*Mn;
            error=norm(Pn_true-Pn_est);
            if error<=minError
                minError=error;
                ansi=i;ansj=j;ansk=k;
                if(error<=0.1)
                    ans=[ans;i,j,k];
                end
                fprintf('i:%d j:%d k:%d error:%f \n',i,j,k,minError);
            end
        end
    end
end
finalAns{1,projIdx}=ans;
end
a1=finalAns{1};
a2=finalAns{2};
a3=finalAns{3};
fprintf('Done..\n');

%% Testing Eq 16 My Matrix 
fprintf('-------------------------\n');
projIdx=6;
momentOrder=4;
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
