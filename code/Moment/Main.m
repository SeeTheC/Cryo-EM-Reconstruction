%% Testing Function
%% Central Moment
f=[1,2,3;4,5,6];
k=0;l=2;
[moment_kl] = centralMoment2D(f,k,l);
moment_kl
%% nthCentralMoment2D
f=[1,2,3;4,5,6];
n=2;
[moment,order,combined] = nthCentralMoment2D(f,n);
