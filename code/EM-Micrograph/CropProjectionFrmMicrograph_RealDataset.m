%% Init
clear all;

addpath('../DataCorrection/');
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification'));

server=1;
fprintf('Server:%d\n',server);
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset/80S_ribosome/Micrographs';
else
    basepath='/media/khursheed/4E20CD3920CD2933/MTP/RealDataset'; 
    basepath=strcat(basepath,'/Micrograph');
end
%----------------------------[Config]-------------------------------
sample='10028';
micrographDir='raw_img';
coordinateMetadata='relion_particles.csv';
patchSize=([18,18]).*12;
%-------------------------------------------------------------------
%basepath=strcat(basepath,'/',sample);
mgPath=strcat(basepath,'/',micrographDir);
coordMetadataPath=strcat(basepath,'/',coordinateMetadata);

%% Process
[status] = cropPosAndNegProjection(mgPath,patchSize,coordMetadataPath,basepath);
fprintf("%s\n",status);
%%


























