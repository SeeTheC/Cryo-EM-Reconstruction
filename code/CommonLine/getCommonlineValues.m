% lineAngle: degree
% proj: Projected image

function [val,x,y,fftProj] = getCommonlineValues(proj,lineAngle)
    %% INIT    
    [m,n]=size(proj);
    %{
    if(mod(m,2)==0)
        %proj=padarray(proj,[1 0],'pre');
        proj=proj(2:end,:);
    end
    if(mod(n,2)==0)
        %proj=padarray(proj,[0 1],'pre');
        proj=proj(:,2:end);
    end
    %}
    
    [m,n]=size(proj);
    hm=(m+1)/2;hn=(n+1)/2;
    ox=hm;oy=hn;
    %{
    if(mod(m,2)==0)
        ox=ox+0.5;
    end
    if(mod(n,2)==0)
        oy=oy+0.5;
    end
    %}
    cellLen=1;
    rad=pi/180;
    
    %% Finding line coordinates at angle: theta with x-axis, assuming center as origin
    x=[hm*-1:cellLen:hm]';
    y=[hn*-1:cellLen:hn]';
    % Formula: x = ox + r cos(theta); |  y = oy + r sin(theta);
    x=ox+(x.*cos(lineAngle*rad));
    y=oy+(y.*sin(lineAngle*rad));    
    %% Find Angles
    fftProj=fft2(proj);
    fftProj=fftshift(fftProj);
    [val]=interp2(fftProj,x,y);
    val(isnan(val))=0;
    
end

