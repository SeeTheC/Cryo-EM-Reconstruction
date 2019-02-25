%% Trys to find common line using the Fourier transform method
function [phi_ij,phi_ji,rmsError] = findPhiBtwTwoProj3UsingFT(proj1,proj2)
     %% INIT     
    incOffset=0.5;
    cellLen=1;
    rad=pi/180;
    rmsError=inf;
    phi_ij=inf;phi_ji=inf;
    
    [m,n]=size(proj1);
    %{
    if(mod(m,2)==0)
        proj1=padarray(proj1,[1 0],'pre');
        proj2=padarray(proj2,[1 0],'pre');
        %proj1=proj1(2:end,:);
        %proj2=proj2(2:end,:);
    end
    if(mod(n,2)==0)
        proj1=padarray(proj1,[0 1],'pre');
        proj2=padarray(proj2,[0 1],'pre');        
        %proj1=proj1(:,2:end);
        %proj2=proj2(:,2:end);
    end
    %}
    [m,n]=size(proj1);
    hm=(m+1)/2;hn=(n+1)/2;
    ox=hm;oy=hn;                
        
    %% Finding line coordinates at angle: theta with x-axis, assuming center as origin
    x=[hm*-1:cellLen:hm]';
    y=[hn*-1:cellLen:hn]';       
    %% Getting Fourier Transform
    fftProj1=fft2(proj1);
    fftProj1=fftshift(fftProj1);
    fftProj2=fft2(proj2);
    fftProj2=fftshift(fftProj2);
    %% find line
    fprintf('Finding Common line ...\n');
    tic
    for ang1=0:incOffset:179
       for ang2=0:incOffset:179
            % Formula: x = ox + r cos(theta); |  y = oy + r sin(theta);
            x1=ox+(x.*cos(ang1*rad));
            y1=oy+(y.*sin(ang1*rad));
            [c1]=interp2(fftProj1,x1,y1);
            c1(isnan(c1))=0;


            % Formula: x = ox + r cos(theta); |  y = oy + r sin(theta);
            x1=ox+(x.*cos(ang2*rad));
            y1=oy+(y.*sin(ang2*rad));
            [c2]=interp2(fftProj2,x1,y1);
            c2(isnan(c2))=0;
            
            % Calulating error
            error=RMSE(c1,c2);
            absError=abs(error);
            if absError<rmsError
                rmsError=absError;
                phi_ij=ang1;
                phi_ji=ang2;                                
            end 
            
            %reverse the C2 i.e rotate line 180
            c2_180=flipud(c2);
            % Calulating error with c2_180
            error=RMSE(c1,c2_180);
            absError=abs(error);
            if absError<rmsError
                rmsError=absError;
                phi_ij=ang1;
                phi_ji=ang2+180; % adding 180 deg                                
            end
       end 
    end
    fprintf('Done.\n');
    toc
end

