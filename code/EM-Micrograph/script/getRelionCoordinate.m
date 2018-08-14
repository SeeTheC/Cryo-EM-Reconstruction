% Read the coordinate from the metadatafile for specific micrograph
function [coordTable,keyword] = getRelionCoordinate(mgFilename,coordMetadataPath)
    fileType=split(coordMetadataPath,'.');
    fileType=fileType{end};    
    if(strcmp(fileType,'csv'))
        tbl = readtable(coordMetadataPath);
        coordTable=tbl(ismember(tbl.name,{mgFilename}),:);
        parts=split(mgFilename,'.');
        keyword=join(parts(1:end-1),'.');
        keyword=keyword{1};
    else
        callPath=pwd;
        scriptPath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/EM-Micrograph/script';
        cd(scriptPath);
        parts=split(mgFilename,'_');
        keyword=join(parts(1:end-1),'_');
        keyword=keyword{1};
        bash_script=sprintf('%s/extract_coordinates.sh %s %s',scriptPath,keyword,coordMetadataPath);
        system(bash_script);
        coordTable = readtable('result.csv','Delimiter',',');
        cd(callPath);        
    end
    fprintf('Done reading result.csv.\n');
end

