function [map,s,mi,ma,av]=ReadMRC(filename,startSlice, numSlices,test)
% function map=ReadMRC(filename);  --all defaults.   Or, with every
% parameter,
% function [map,s,mi,ma,av]=ReadMRC(filename,startSlice, numSlices,test)
%
% Read a 3D map from a little-endian .mrc file
% and return a structure containing various parameters read from the file.
% This function reads 2d and 3d real maps in byte, int16 and float32 modes.
% Added interpretation of the extended header (length = c(2) which is important with imod and
% serialEM at Brandeis.  lw 15 Aug 07
% Added error tests.  fs 2 Sep 07
% Added the ability to read selected slices, and read big-endian files
% fs 17 Sep 09
% Changed the a array so that the returned s values are doubles.  5 Nov 09
% Added data mode 6 (unsigned int16) fs 20 Jan 10
% Changed s fields to doubles fs 20 Feb 10

if nargin<2
    startSlice=1;
end;
if nargin<3
    numSlices=inf;
end;
if nargin<4
    test=0;
end;

% We first try for little-endian data
f=fopen(filename,'r','ieee-le');
if f<0
    error(['in ReadMRC the file could not be opened: ' filename])
end;
% Get the first 10 values, which are integers:
% nc nr ns mode ncstart nrstart nsstart nx ny nz
a=fread(f,10,'*int32');

if abs(a(1))>1e5  % we must have the wrong endian data.  Try again.
    fclose(f);
    f=fopen(filename,'r','ieee-be');
    a=fread(f,10,'int32');  % convert to doubles
end;

if test
    a(1:10)
end;

mode=a(4);

% Get the next 12 (entries 11 to 23), which are floats.
% the first three are the cell dimensions.
% xlength ylength zlength alpha beta gamma mapc mapr maps
% amin amax amean.
[b,cnt]=fread(f,12,'float32');
if test
   b
end;

% b(4,5,6) angles
mi=b(10); % minimum value
ma=b(11); % maximum value
av=b(12);  % average value

s.rez=double(b(1)); % cell size x, in A.

% get the next 30, which brings us up to entry no. 52.
[c,cnt]=fread(f,30,'*int32');
if test, c(1:3), end;
% c(2) is the extended header in bytes.

% the next two are supposed to be character strings.
[d,cnt]=fread(f,8,'*char');
d=d';
s.chars=d;
if test
    d    
end;

% Two more ints...
[e,cnt]=fread(f,2,'*int32');
if test, e, end;

% up to 10 strings....
ns=min(e(2),10);
for i=1:10
	[g,cnt]=fread(f,80,'char');
	str(i,:)=char(g)';
end;
% disp('header:'); disp(' ');
% disp(str(1:ns,:));
% disp(' ');
s.header=str(1:ns,:);

% Get ready to read the data.
s.nx=double(a(1));
s.ny=double(a(2));
s.nz=double(a(3));

switch mode
    case 0
        string='*uint8';
        pixbytes=1;
    case 1
        string='*int16';
        pixbytes=2;
    case 2
        string='*float32';
        pixbytes=4;
    case 6
        string='*uint16';
    otherwise
        error(['ReadMRC: unknown data mode: ' num2str(mode)]);
        string='???';
        pixbytes=0;
end;

if(c(2)>0)
    [ex_header,cnt]=fread(f,c(2),'char');   
    disp(['Read extra header of ',num2str(c(2)),' bytes!'])
%    disp((ex_header'));
end

skipbytes=0;
nz=s.nz;
if startSlice>1
    skipbytes=(startSlice-1)*s.nx*s.ny*pixbytes;
    fseek(f,skipbytes,'cof');
    nz=min(s.nz-(startSlice-1),numSlices);
end;
ndata=s.nx * s.ny * nz;
if test
    string
    ndata
end;

[map,cnt]=fread(f,ndata,string);
fclose(f);

if cnt ~= ndata
    error('ReadMRC: not enough data in file.');
end;
map=reshape(map,s.nx,s.ny,nz);