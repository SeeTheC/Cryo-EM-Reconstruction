function [status] = cropPosAndNegProjection(mgPath,patchSize,coordMetadataPath,basepath)
    status='Incomplete';
    %% Init
    timestamp=datestr(now,'dd-mm-yyyy HH:MM:SS');
    halfWidth=ceil(patchSize(1)./2);halfHeight=ceil(patchSize(1)./2);
    
    savepath=strcat(basepath,'/projection_',timestamp);
    savePosPath=strcat(savepath,'/positive');
    savePosPathImg=strcat(savePosPath,'/img');
    savePosPathRaw=strcat(savePosPath,'/raw_img');

    saveNegPath=strcat(savepath,'/negative');
    saveNegPathImg=strcat(saveNegPath,'/img');
    saveNegPathRaw=strcat(saveNegPath,'/raw_img');

    mkdir(savepath);
    mkdir(savePosPath);mkdir(savePosPathImg);mkdir(savePosPathRaw);
    mkdir(saveNegPath);mkdir(saveNegPathImg);mkdir(saveNegPathRaw);
    
    fprintf('Init Done.\n');
    %% Process
    fileNameList=getDirFilesName(mgPath);
    noOfMg=size(fileNameList,2);
    totalPosParticleCount=0;
    totalNegParticleCount=0;
    for m=1:noOfMg
        mgName=fileNameList{m};
        mgFile=strcat(mgPath,'/',mgName);
        [img,~,~,~,~]=ReadMRC(mgFile);
        %img=img-min(img(:));
        %micrograph=img/max(img(:));
        micrograph=img; 
        [mgH,mgW]=size(micrograph);
        [coordTable,keyword] = getRelionCoordinate(mgName,coordMetadataPath);
        noOfParticle=size(coordTable,1);
        for pidx=1:noOfParticle
            fprintf('%s\tpartice_%d\n',keyword,totalPosParticleCount);
            row=coordTable(pidx,:);
            cx=row.x;cy=row.y;
            %% Positive Partice
            totalPosParticleCount=totalPosParticleCount+1;
            [x1,x2,y1,y2] = getPatchCoordinat(cx,cy,patchSize);
            if(x1>0 && x2<=mgH && y1>0 && y2<=mgW)            
                particle=micrograph(x1:x2,y1:y2);
                img=particle;
                save(strcat(savePosPathRaw,'/',num2str(totalPosParticleCount),'.mat'),'img');
                img=img-min(img(:));img=img/max(img(:));
                imwrite(img,strcat(savePosPathImg,'/',num2str(totalPosParticleCount),'.png'));
            else
                fprintf('INVAILD COORDINATE: x1:%d y1:%d x2:%d y2:%d\n',x1,y1,x2,y2);
            end
            %% Negative Partice 1 
            totalNegParticleCount=totalNegParticleCount+1;
            [x1,x2,y1,y2] = getPatchCoordinat(cx+halfHeight,cy-halfWidth,patchSize);
            if(x1>0 && x2<=mgH && y1>0 && y2<=mgW)
                particle=micrograph(x1:x2,y1:y2);img=particle;
                save(strcat(saveNegPathRaw,'/',num2str(totalNegParticleCount),'.mat'),'img');
                img=img-min(img(:));img=img/max(img(:));
                imwrite(img,strcat(saveNegPathImg,'/',num2str(totalNegParticleCount),'.png'));
            end 
            
            %% Negative Partice 12
            totalNegParticleCount=totalNegParticleCount+1;
            [x1,x2,y1,y2] = getPatchCoordinat(cx-halfHeight,cy-halfWidth,patchSize);
            if(x1>0 && x2<=mgH && y1>0 && y2<=mgW)
                particle=micrograph(x1:x2,y1:y2);img=particle;
                save(strcat(saveNegPathRaw,'/',num2str(totalNegParticleCount),'.mat'),'img');
                img=img-min(img(:));img=img/max(img(:));
                imwrite(img,strcat(saveNegPathImg,'/',num2str(totalNegParticleCount),'.png'));
            end 
        end    
    end
    fprintf('\nPlease check dir %s\n.',savepath');
    status=strcat('Postive:',num2str(totalPosParticleCount),' Negative:',num2str(totalNegParticleCount),'.Completed.');
    fprintf('Done.\n');

end

