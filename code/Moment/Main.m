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
