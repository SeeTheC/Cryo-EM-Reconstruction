% Read the coordinate from the metadatafile for specific micrograph
function [coordTable] = getAllCoordinate(coordMetadataPath)
    callPath=pwd;
    scriptPath='~/git/Cryp-EM/Cryo-EM-Particle-Picking/code/Projection/EM-Micrograph/script';
    cd(scriptPath);
    bash_script=sprintf('%s/extract_all_coordinates.sh %s',scriptPath,coordMetadataPath);
    system(bash_script);
    coordTable = readtable('result.csv','Delimiter',',');
    cd(callPath);
    fprintf('Done reading result.csv.\n');
end
