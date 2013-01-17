clear all
close all

%envdir = sw06_get_filepath('sw06_envdir');
envdir = '/Volumes/sw06 working disk/sw06_process_tools/sw06_event50_PE/mat_original/env/';
envfiles = dir([envdir,'SW50EVT50_ENV*.mat']);

% pedir = sw06_get_filepath( 'sw06_pe_result');

contour_vec = [ 70:5:90];
% contour_vec = [80 80];
c_axis = [18 25];
figure;
for ix = 1:length(envfiles)
    clf
    info = sw06_pe_envinfo(envfiles(ix).name);
%     pefile = dir([pedir, sprintf('SW50EVT50_event50_3DWAPE_freq_%d_%s.mat',info.freq,datestr(info.time,'ddmmmyy_HHMMSS'))]);
%     
%     if isempty(pefile) || pefile.bytes < 50e6
%         continue;
%     end
%     load([pedir, pefile.name]);
    
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
    %plot([0 TEMPR.src2rcvdist],[0 0],'-yp','linewidth',4,'markersize',10)
    title(envfiles(ix).name,'Interpreter','none');
    print('-dpng',[envdir, envfiles(ix).name(1:end-3),'png']);
    %pause
end