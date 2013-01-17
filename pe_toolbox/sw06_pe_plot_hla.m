clear
close all

trans = sw06_event50_transmission('j15');

datadir = '..\mat\vla\';
files = dir([datadir,'SW50EVT50*.mat']);
sourcename = 'j15';
shark_hla = sw06_rcvr_config('shark_hla');
source = sw06_mooring_position('j15');
[source.x source.y] = sw06_sph2grid3(source.LONGITUDE,source.LATITUDE);
for ix=1:size(shark_hla.location,1)
    [shark_hla.x(ix) shark_hla.y(ix)] = sw06_sph2grid3(shark_hla.location(ix,1),...
        shark_hla.location(ix,2));
end

if strcmp(sourcename,'j15')
    f0=250;
elseif strcmp(sourcename,'nrl300')
    f0=300;
end

c0=1500;
ny=2^12; numperlambday=5;
nz=2^10; numperlambdaz=4;
lambda0=c0/f0;
wid = ny*lambda0/numperlambday;  % horizontal width

aspect = wid/(nz*lambda0/numperlambdaz);  % y-to-z ratio


dy=wid/ny;
dz=wid/aspect/nz;
y=(-0.5*ny*dy):dy:(0.5*ny*dy)-dy;
z=(-0.5*nz*dz):dz:(0.5*nz*dz)-dz;
[Y,Z]=meshgrid(y,z);
k0=2*pi*f0/c0;  % 2 pi   over lambda = ko
Lrho = 2*c0/f0; % default number 2*lambda0
wd = max(shark_hla.depth);
[H,dH,d2Hin] = sw06_pe_sub_mixing_function_rho(abs(Z)-wd,Lrho); % remember to keep d2Hin
rhow=1;
rhob=1.5;

denin = rhow+(rhob-rhow)*H;

for ix_t = 3
    n = 0;
    for ix_f = 1:length(files)
        matinfo = sw06_PE_matfileinfo(files(ix_f).name);
        if matinfo.time < trans.time(ix_t,1) || matinfo.time > trans.time(ix_t,2)
            continue;
        end
        n = n+1;
        load([datadir,files(ix_f).name]);
        
        pe.geotime(n)=matinfo.time;
        if matinfo.freq ~=f0
            error('wrong f0');
        end
        
        sx = interp1(source.GMT, source.x, pe.geotime);
        sy = interp1(source.GMT, source.y, pe.geotime);
        shark_hla.z_index = max(find(z<=-max(shark_hla.depth)));
        sl = (sx.^2 + sy.^2).^.5;
        theta1 = atan2(max(shark_hla.y), max(shark_hla.x));
        theta2 = atan2(sy, sx);
        theta = theta1-theta2;
        
        psifinal=ifftshift(psi)*exp(i*k0*dista).*sqrt(denin);
        
        pe.intens(n)=interp1(y, 20*log10(abs(psifinal(shark_hla.z_index,:))),(sl-dista)*tan(theta));

    end
end

