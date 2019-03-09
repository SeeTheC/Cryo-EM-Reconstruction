% It will find lines at some angle in Fourier domain, Similart to get1DProjections
% angResolution : 1 (default)
function [projLines] = getAllFourierDomainCL(proj,angResolution)
    %% INIT
<<<<<<< HEAD
    N = size(proj,3);
    %N=10; % TEMP; DEBUG
=======
    N = size(proj,3); 
>>>>>>> 84a39d7eaf66bffde88ab4024e724c8b83d4bbbb
    [m,n]=size(proj(:,:,1));
    hm=(m+1)/2;hn=(n+1)/2;
    ox=hm;oy=hn;
    digLen=sqrt(m^2+n^2);
    halfDig=ceil(digLen/2);
    pixelDist=1;
    rad=pi/180;
<<<<<<< HEAD
    % GPU Array init
    proj=gpuArray(proj);    
     %% Finding line coordinates at angle: theta with x-axis, assuming center as origin
    %x=[halfDig*-1:pixelDist:halfDig]';
    %y=[halfDig*-1:pixelDist:halfDig]';   
    x=[hm*-1:pixelDist:hm]';
    y=[hn*-1:pixelDist:hn]';
    
    ang=[0:angResolution:180-(1e-10)];
=======
     %% Finding line coordinates at angle: theta with x-axis, assuming center as origin
    x=[halfDig*-1:pixelDist:halfDig]';
    y=[halfDig*-1:pixelDist:halfDig]';   
    ang=[0:angResolution:179];
>>>>>>> 84a39d7eaf66bffde88ab4024e724c8b83d4bbbb
    angCount=numel(ang);
    x1=repmat(x,[1 angCount]);
    y1=repmat(y,[1 angCount]);
    cosAng=cos(ang.*rad);
    sinAng=sin(ang.*rad);
    
    % Formula: x = ox + r cos(theta); |  y = oy + r sin(theta);   
    x1=bsxfun(@times,x1,cosAng);
    y1=bsxfun(@times,y1,sinAng);
    x1=ox+x1;
    y1=oy+y1;
    
    %% finding lines
<<<<<<< HEAD
    parfor i=1:N
        p=proj(:,:,i);
        fpi=fftshift(fft2(p));
        [lines]=interp2(fpi,x1,y1);
        lines(isnan(lines))=0;
        lines=lines';
        lines=[lines;fliplr(lines)];
        projLines(:,:,i)=gather(lines);        
    end
=======
        
>>>>>>> 84a39d7eaf66bffde88ab4024e724c8b83d4bbbb
end

