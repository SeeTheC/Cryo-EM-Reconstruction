
%% Testing Function
addpath(genpath('../../lib/3dviewer'));
addpath(genpath('../MapFileReader/'));

%% Central Moment
f=[1,2,3;4,5,6];
k=0;l=2;
[moment_kl] = centralMoment2D(f,k,l);
moment_kl
%% nthCentralMoment2D
f=[1,2,3;4,5,6];
n=2;
[moment,order,combined] = nthCentralMoment2D(f,n);

%% weight(Ri,k,l,alpha)
ax=0;ay=0;az=0;
Ri=rotationMatrix(ax,ay,az);
k=2,l=0;
alpha=[1,1,0];
a=weight(Ri,k,l,alpha);


%% Test CASE Two 360^2*180
% Result: Elapsed time is 0.029516 seconds.
a=0;
tic
for i=1:23328000
    a=a+1;
end
toc
fprintf('Done');

%% Test CASE Two 360^2*180
% Result: 108.281063 seconds. : 2mins

A=rand(100,200)*10;
IM=rand(200,1)*10;
P=rand(100,1)*10;

tic
for i=1:23328000
    B=norm(P-A*IM);
end
toc
fprintf('Done');

%% TEST : weightMtxUptoCMultAng
clear all
range=360-1;
tic
A = [0:range];
B = [0:range];
C = [0:range];
[aa,bb,cc] = ndgrid(A,B,C) ;
R = [cc(:) bb(:) aa(:)] ;
toc
clear aa bb cc;
%% TEST : COMMON LINE




