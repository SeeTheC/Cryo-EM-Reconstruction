%% INIT
base='/home/khursheed/git/Dataset/EM/EM-10025';
emxFile=strcat(base,'/','10025.emx');
%% ReadingXML
domnode=xml2struct(emxFile);
fprintf('Done.');
%%