clear all
close all

datadir = '/Volumes/sw06 working disk/temp/3D_ENV_for_porter/';
files = dir([datadir,'*.mat']);



for ix_f = 1:length(files)
    if files(ix_f).bytes<50e6
        continue;
    end
    
    
    load([datadir,files(ix_f).name]);
    envfilename = ['SW50EVT50_ENV_freq_',num2str(freq),'_',files(ix_f).name(end-17:end)];
    save([datadir,envfilename],'TEMPR','BATHY','freq');
    
end

clear all;
datadir = '/Volumes/sw06 working disk/temp/3D_ENV_for_porter/';

envdir = datadir;
envfiles = dir([envdir,'SW50EVT50_ENV*.mat']);


contour_vec = [ 70:5:90];
c_axis = [18 25];
figure;
for ix = 1:length(envfiles)
    clf
    
    load([envdir,envfiles(ix).name])
    [tx, ty] = meshgrid(TEMPR.PEgridx,TEMPR.PEgridy);
    pcolor(tx/1000,ty/1000,TEMPR.temp(:,:,4))
    shading flat
    hold on
    [C h]=contour(BATHY.x/1000, BATHY.y/1000, BATHY.z, contour_vec,'w');
    clabel(C,h);
    caxis(c_axis)
    set(gca,'dataAspectRatio',[1 1 1]);
    xlabel('km');
    ylabel('km');
    title(envfiles(ix).name,'Interpreter','none');
    print('-dpng',[envdir, envfiles(ix).name(1:end-3),'png']);
    %pause
end