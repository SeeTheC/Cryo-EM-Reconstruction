% Returns the files name of the give dir in sorted order
function [ fldFileNames ] = getDirFilesName(dirpath,filterByExtension)
    folder = dir(dirpath);
    fldFileNames =natsortfiles({folder.name});    
    fldFileNames=fldFileNames(1,3:end);
    if(nargin>1 && numel(filterByExtension)~=0)
        n=size(fldFileNames,2);
        fltFileName=cell(0,1);
        idx=1;
        for i=1:n
            name=fldFileNames{i};
            temp=split(name,'.');
            if(strcmp(temp{end},filterByExtension))
                fltFileName{idx}=name;
                idx=idx+1;
            end
        end
        fldFileNames=fltFileName;
    end
end

