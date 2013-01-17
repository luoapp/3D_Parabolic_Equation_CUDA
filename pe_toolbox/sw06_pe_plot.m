clear
close all



trans = sw06_event50_transmission('j15');
f0=250;
datadir = sw06_get_filepath( 'sw06_pe_result');
files = dir([datadir,'*.mat']);

figuredir = sw06_get_filepath( 'sw06_pe_temp_intens_fig');
shark_vla = sw06_rcvr_config('shark_vla');

for ix_f = 1:length(files)
    if files(ix_f).bytes<50e6
        continue;
    end
    
    info = sw06_pe_matfileinfo(files(ix_f).name);
    if info.freq == 250
        info.source = 'J15';
    else
        info.source = 'NRL300';
    end
    
    
    figure_filename = sprintf('sw06_event50_Temp_Intens_freq_%d_%s.png',...
        info.freq,datestr(info.time,'ddmmmyy_HHMMSS'));
    if ~isempty(dir([figuredir,figure_filename]))
        continue;
    end
    
    load([datadir,files(ix_f).name]);
    
    figure(51); clf
    yplot_max = wid/2*.8;
    set(gcf,'papersize',[11.5 8],'PaperPosition',[0.25 0.25 11 7.5],'PaperPositionMode','auto')
    [xtmp,ytmp]=meshgrid(x,y(abs(y)<=yplot_max));
    rrr=sqrt(xtmp.^2+ytmp.^2);
    set(gcf,'position',[  35         352        1566         732]);
    pos = [0.100    0.100    0.750    0.8150];
    pos2 = [0.87 0.15 0.02 0.3];
    pos3 = [0.93 0.15 0.02 0.3];
    pos4 = [0.87 0.5 0.1 0.2];
    pos5 = [0.87 0.65 0.1 0.2];
    
    intens_lim = [ -15, 7];
    intens_clim = [-15 3];
    
    ax0 = axes;
    set(ax0,'position',pos);
    ax1 = axes;
    set(ax1,'position',pos);
    axb0 = axes;    set(axb0,'position',pos2,'fontsize',8);
    axb1 = axes;    set(axb1,'position',pos3,'fontsize',8);
    axb4 = axes;    set(axb4,'position',pos4,'fontsize',8);
    axb5 = axes;    set(axb5,'position',pos5,'fontsize',8);
    axes(ax0);
    TEMPix = abs(TEMPR.PEgridy)<=yplot_max;
    temp_handle = imagesc(TEMPR.PEgridx/1000,TEMPR.PEgridy(TEMPix)/1000,TEMPR.temp(TEMPix,:,4));
    set(temp_handle, 'alphadata',0.25)
    % [tx, ty] = meshgrid(TEMPR.PEgridx,TEMPR.PEgridy(TEMPix));
    
    %temp_handle = pcolor(tx/1000,ty/1000,TEMPR.temp(TEMPix,:,4));       shading flat
    axis equal; axis tight;axis off; box off
    
    x_lim = get(gca,'xlim');    y_lim = get(gca,'ylim');
    axis([x_lim, y_lim]);
    set(gca,'tickdir','out','fontsize',12,'ydir','normal')
    
    axes(axb0);    ch = colorbar(axb0,'peer',ax0);  set(get(ch,'title'),'string','^oC')
    
    axes(axb4);
    imagesc(TEMPR.PEgridx/1000,TEMPR.PEgridy(TEMPix)/1000,TEMPR.temp(TEMPix,:,4));
    axis equal; axis tight;
    xlabel('Temperature');
    set(gca,'ydir','normal');
    
    axes(axb5)
    imagesc(x/1000,y(abs(y)<=yplot_max)/1000,10*log10(Ez(:,abs(y)<=yplot_max)'.*rrr));
    axis equal; axis tight
    xlabel('Sound intensity');
    set(gca,'ydir','normal');
    
    
    axes(ax1)
    contour(x/1000,y(abs(y)<=yplot_max)/1000,10*log10(Ez(:,abs(y)<=yplot_max)'.*rrr),[intens_lim(1):0.25:intens_lim(2)],'linewidth',1);
    caxis(intens_clim);
    set(ax1,'position',pos,'color','none')
    axis equal; axis tight
    ylabel('Distance (km)','fontsize',12)
    xlabel('Distance (km)','fontsize',12)
    
    axes(axb1);imagesc(0,linspace(intens_lim(1), intens_lim(2),255),linspace(intens_lim(1),intens_lim(2),255)');
    set(get(axb1,'title'),'string','dB');set(axb1,'YAxisLocation','right','ydir','normal','xticklabel','')
    
    axes(ax0)
    
    
    title([datestr(PEcoor.time,'HH:MM:SS dd/mmm'),'GMT ',...
        'Temperature and Intensity (',info.source,')  '...
        ],'fontsize',14)
    %    axis([x_lim, y_lim]);
    
    saveSameSize(gcf,'format','png','file',[figuredir,figure_filename])
    %     continue;
    %     figure(52); clf
    %     filename = sprintf('SW50EVT50_%s_BottomSndLv_freq_%d_%s.png',...
    %         icase,freq,datestr(PEcoor.time,'ddmmmyy_HHMMSS'));
    %     yplot_max = wid/2*.8;
    %     set(gcf,'papersize',[11.5 8],'PaperPosition',[0.25 0.25 11 7.5])
    %     [xtmp,ytmp]=meshgrid(x,y(abs(y)<=yplot_max));
    %     rrr=sqrt(xtmp.^2+ytmp.^2);
    %     %     pcolor(x/1000,y(abs(y)<=yplot_max)/1000,10*log10(Ez(:,abs(y)<=yplot_max)'.*rrr));
    %     %     shading flat
    %     imagesc(x/1000,y(abs(y)<=yplot_max)/1000,10*log10(Ez_hla(:,abs(y)<=yplot_max)'.*rrr));
    %     set(gca,'ydir','normal');
    %
    %     hold on; caxis([-100 -10]); colormap(jet(15))
    %     ch = colorbar; set(get(ch,'ylabel'),'string','dB','fontsize',12)
    %     title(strvcat([datestr(PEcoor.time,'HH:MM dd/mmm') ' UTC '],...
    %         'Sound Level at bottom',...
    %         '0 dB Source Level and Cylindrical Spreading Loss Compensated'),'fontsize',14)
    %     ylabel('Distance (km)','fontsize',12)
    %     xlabel('Distance (km)','fontsize',12)
    %     set(gca,'tickdir','out','fontsize',12)
    %     axis equal; axis tight;
    %     %print('-dpng','-r72',filename)
end