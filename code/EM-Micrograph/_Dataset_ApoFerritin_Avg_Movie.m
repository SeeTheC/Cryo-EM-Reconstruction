%% Avg. the movie file
clear all;
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification'));
addpath(genpath('../DataCorrection/'));

%% INIT
server=3;
fprintf('Server:%d\n',server);
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server==3
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/mtp-data/RealDataset/Apo-Ferritin';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset/Apo-Ferritin';
end

movieBPath=strcat(basepath,'/Movie_Micrographs');
savePath=strcat(basepath,'/Avg_Micrographs');

%% Process

% Reading Files Name
filename=getDirFilesName(movieBPath);
noOfMg=numel(filename);
fprintf('** Number of Micrograph to process:%d\n',noOfMg);

% Process each Micrograph
for i=1:noOfMg
    fullfn=filename{i};
    fprintf('Processing Mg(%d/%d): %s\n',i,noOfMg,fullfn);
    fn=split(fullfn,'.');
    fn=fn{1};
    file=strcat(movieBPath,'/',fullfn);
    [img,s,mi,ma,av]=ReadMRC(file);
    micrograph=mean(img,3);
    save(strcat(savePath,'/',fn,'.mat'),'micrograph');
end    
fprintf('Done\n');
%% Load TESTING
%l=strcat(savePath,'/',fn,'.mat');
%mg=load(l);
%mg=mg.micrograph;



