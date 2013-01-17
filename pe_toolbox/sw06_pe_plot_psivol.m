clear all;
bindir = 'D:\Jing\matlib\bin\';
cudafile = 'd:\jing\matlib\bin\freq270__17Aug06_213000_cuda.mat';
envfiledir = 'D:\Jing\pe_curve\mat\env\';
pedir = 'D:\Jing\matlib\bin\';

idx = [2:2:900];

for ix = length(idx):-1:1
    
    if ~exist('ny','var')
        
        load([cudafile]);
        info = sw06_pe_matfileinfo(outfile);
        envfilename = sprintf('%sSW50EVT50_ENV_%s_%s.mat',envfiledir,info.source,...
            datestr(info.time,'ddmmmyy_HHMMSS'));
        load([envfilename]);
        load(ssp3dfield_filename);
        load([pedir,outfile]);
        frq = freq;
        lambda=c0/frq ;
        dx=steplength;
        dy=wid/ny;
        dz=wid/aspect/nz;
        y=(-0.5*ny*dy):dy:(0.5*ny*dy)-dy;
        z=(-0.5*nz*dz):dz:(0.5*nz*dz)-dz;
        %[Y,Z]=meshgrid(y,z);
        idz(1) = find(z>=0,1,'first');
        idz(2) = find(z>=WD, 1, 'first');
        
        z0 = z;
        z=z(idz(1):idz(2)-1);
        nz1 = length(z);
        x=[0 (ndxout:ndxout:numstep)*steplength];
        x0 = x;
        x = x(idx);
        psivol = zeros(length(idx),ny,nz1);
    end
    
    filename = sprintf('psifinal%04d.bin',idx(ix));
    fid = fopen([bindir, filename]);
    s = fread(fid, 'float');
    fclose(fid);
    s1 = s(1:2:end)+(-1)^0.5*s(2:2:end);
    s2=reshape(s1,[ny, nz1]);
    psivol(ix,:,:) = reshape(s1,[ny, nz1]);
   % imagesc(y,z_short,abs(squeeze(psivol(ix,:,:))).')
   % set(gca,'xlim',[0 1000]);
   % pause
end



idx1 = 1:3:length(x);
idy1 = 1000:40:3000;
idz1 = 1:length(z);
s3 = psivol(idx1, idy1, idz1);
x1 = x(idx1);
y1 = y(idy1);
z1 = z(idz1);

p = patch(isosurface(y1,x1,z1,s3,0.6e-3));
set(p,'facecolor', 'red','edgecolor','none');
colormap(jet);
box on;
axis tight;
camproj perspective;
camlight left;
lighting gouraud;
