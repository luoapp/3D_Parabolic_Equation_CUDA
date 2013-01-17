clear
close all
for sourcename1 = {'J15'}
    sourcename = sourcename1{:};
    trans = sw06_event50_transmission(sourcename);
    datadir = '../mat/vla/';
    figdir = '../figures/vla/';
    files = dir([datadir,'SW50EVT50*.mat']);
    %x_axis = datenum([2006 8 17 20 0 0]):5/60/24:datenum([2006 8 17 24 0 0]);
    x_axis = 0:30;
    if strcmp(sourcename,'J15')
        f0=250;
        transid = 'M';
    elseif strcmp(sourcename,'NRL300')
        f0=300;
        transid = 'F';
    end
    
    shark_vla = sw06_rcvr_config('shark_vla');
    z1=-[1:1:max(shark_vla.depth)];
    for ix_t = 1: size(trans.time,1)
        vf=dir([sprintf('%sSW06_PE_%s_%s%d_VLA',figdir,sourcename,transid,ix_t),'.mat']);
        f1 = pwd;
        if ~isempty(vf) && length(f1)==49
            load([sprintf('%sSW06_PE_%s_%s%d_VLA',figdir,sourcename,transid,ix_t),'.mat']);
            gt = (pe.geotime-min(pe.geotime))*60*24;
            [xt yt]=meshgrid(gt, z1);
            pcolor(xt, yt, intens');shading flat
            
            %imagesc(pe.geotime,z1,intens');
            set(gca,'ydir','normal')
            %datetick
            set(gca,'xtick',x_axis);
            set(gca,'xlim',[gt(1) gt(end)]);
            set(gca,'fontsize',12,'fontweight','bold');
            ylabel('Depth(m)');
            xlabel('Geotime');
            title({['Received signal on Shark VLA during ',sourcename,' ',transid,num2str(ix_t),' transmission'],...
                [ datestr(pe.geotime(1)),' ~ ', datestr(pe.geotime(end))]});
            colorbar
            print('-dpng',sprintf('%sSW06_PE_%s_%s%d_VLA.png',figdir,sourcename,transid,ix_t))
            
        end
    end
end