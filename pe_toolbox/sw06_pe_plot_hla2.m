clear
close all
shark_hla = sw06_rcvr_config('shark_hla');
for ix=1:size(shark_hla.location,1)
    [shark_hla.x(ix) shark_hla.y(ix)] = sw06_sph2grid3(shark_hla.location(ix,1),...
        shark_hla.location(ix,2));
end

shark_hla.dist = (shark_hla.x.^2 + shark_hla.y.^2).^.5;
x_axis = 0:30;


datadir = '../mat/hla/';
files = dir([datadir,'*hla.mat']);
figdir = '../figures/hla/';

for ix_f = 1:length(files)
    
    
    info = sw06_pe_matfileinfo(files(ix_f).name);
    load([datadir,files(ix_f).name]);
    gt = (pe.geotime-min(pe.geotime))*60*24;
    
    [xt2, yt2] = meshgrid(gt,...
        linspace(shark_hla.dist(1), shark_hla.dist(end), size(hla,1)));
    clf
    pcolor(xt2,yt2,10*log10(hla))
    box on;
    set(gca,'ydir','reverse');
    shading flat
    box on
    set(gca,'xtick',x_axis);
    set(gca,'xlim',[gt(1) gt(end)]);
    set(gca,'fontsize',12,'fontweight','bold');
    ylabel('Dist. to Shark VLA(m)');
    xlabel('Geotime');
    title({['Received signal on Shark HLA during ',info.sourcename,' ',info.trans,' transmission'],...
        [ datestr(pe.geotime(1)),' ~ ', datestr(pe.geotime(end))]});
    colorbar
    print('-dpng',sprintf('%sSW06_PE_%s_%s_HLA.png',figdir,info.sourcename,info.trans))
    
end