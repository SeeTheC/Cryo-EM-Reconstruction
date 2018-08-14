%% Parse all file
clear all;
addpath(genpath('../MapFileReader/'));
addpath(genpath('../Classification'));
addpath(genpath('../DataCorrection/'));
addpath(genpath('script/'));

%% INIT
server=2;
fprintf('Server:%d\n',server);
timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
if server==3
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/mtp-data/RealDataset/80S_ribosome/Micrographs';
elseif server==2
    basepath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/data/RealDataset/80S_ribosome/Micrographs';
end

mrcBPath=strcat(basepath,'/raw_img');
particleBPath=strcat(basepath,'/relion_star');
savePath=strcat(basepath);

%% Process

% Reading Files Name
filename=getDirFilesName(mrcBPath,'mrc');
noOfMg=numel(filename);
fprintf('** Number of Micrograph to process:%d\n',noOfMg);

%% Process each Micrograph
for i=1:1%noOfMg
    fullfn=filename{i};
    fprintf('Processing Mg(%d/%d): %s\n',i,noOfMg,fullfn);
    fn=split(fullfn,'.');
    fn=fn{1};
    file=strcat(mrcBPath,'/',fullfn);
    [mg,s,mi,ma,av]=ReadMRC(file);
    %micrograph=mean(img,3);
    %save(strcat(savePath,'/',fn,'.mat'),'micrograph');
end    
fprintf('Done\n');
%% Load TESTING
%l=strcat(savePath,'/',fn,'.mat');
%mg=load(l);
%mg=mg.micrograph;
%% TESTING MARKING
markingFile=strcat(particleBPath,'/','part1_001_autopick.star');
tbl=getAllCoordinate(markingFile);

%%
img=imresize(double(mg),1);
img=img/max(img(:));
lineWidth=3;predictColor='red';
%mark center
% predicted center    
for r= 1:size(table,1)
    cx=table{r,:}(1);cy=table{r,:}(2);
    fprintf('Particle: i:%d x:%d y:%d\n',r,cx,cy);
    markSize=20;
    img=insertMarker(img,[cy,cx],'x','color',predictColor,'size',markSize);    
    for w=1:lineWidth
        img=insertMarker(img,[cy-w,cx],'x','color',predictColor,'size',markSize); 
        img=insertMarker(img,[cy,cx-w],'x','color',predictColor,'size',markSize);    
        img=insertMarker(img,[cy+w,cx],'x','color',predictColor,'size',markSize);    
        img=insertMarker(img,[cy,cx+w],'x','color',predictColor,'size',markSize);    

    end
end
fprintf('Done\n');
imshow(img);
%% Draw box: Fullscale MG
%idx=206; good one
idx=20;
img=mg;
boxSize=[216,216];
%boxSize=boxSize.*downsample;
figure,imshow(img,[]),impixelinfo;
for i=1:height(tbl)
    cx=tbl(i,:).Var1;cy=tbl(i,:).Var2;
    [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,boxSize);
    fprintf('x1:%d x2:%d y1:%d y2:%d\n',x1,x2,y1,y2);
    rectangle('Position',[y1,x1,boxSize(2),boxSize(1)],...
          'EdgeColor', 'r',...
          'LineWidth', 1,...
          'LineStyle','-');
end

%% Creating common partice marking for All micrograph

%%
% Reading Files Name
filename=getDirFilesName(mrcBPath,'star');
noOfStar=numel(filename);
fprintf('** Number of Particle Files to process:%d\n',noOfStar);

finalTable=cell2table(cell(0,3));
finalTable.Properties.VariableNames={'name','x','y'};
for i=1:noOfStar
    file=filename{i};
    temp=split(file,'_autopick.star');
    name=strcat(temp{1},'.mrc');    
    fprintf('--Processing File-%d : %s\n',i,name);
    markingFile=strcat(mrcBPath,'/',file);
    tbl=getAllCoordinate(markingFile);
    noOfParticles=height(tbl);
    fprintf('No of Paticles:%d\n',noOfParticles);
    nameCol=cell(noOfParticles,1);
    nameCol(:)={name};
    tmpTbl=[nameCol,tbl];
    tmpTbl.Properties.VariableNames={'name','x','y'};
    finalTable=[finalTable;tmpTbl];
    %filter: finalTable(ismember(finalTable.name,{'aa'}),:)
end
fprintf('Saving table..');
writetable(finalTable,strcat(savePath,'/','relion_particles.csv'));
fprintf('Done.\n');

%%
markingFile=strcat(mrcBPath,'/','part1_001_autopick.star');
tbl=getAllCoordinate(markingFile)

