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
    if info.time ~= datenum([2006 8 17 21 36 0])
        continue;
    end
    
    load([datadir,files(ix_f).name]);
    
    figure(51); clf
    filename = sprintf('SW50EVT50_%s_DpthIntgSndLv_freq_%d_%s.png',...
        icase,freq,datestr(PEcoor.time,'ddmmmyy_HHMMSS'));
    yplot_max = wid/2*.8;
    set(gcf,'papersize',[11.5 8],'PaperPosition',[0.25 0.25 11 7.5])
    [xtmp,ytmp]=meshgrid(x,y(abs(y)<=yplot_max));
    rrr=sqrt(xtmp.^2+ytmp.^2);
%     pcolor(x/1000,y(abs(y)<=yplot_max)/1000,10*log10(Ez(:,abs(y)<=yplot_max)'.*rrr));
%     shading flat
    imagesc(x/1000,y(abs(y)<=yplot_max)/1000,10*log10(Ez(:,abs(y)<=yplot_max)'.*rrr));
    set(gca,'ydir','normal');
    
    hold on; caxis([-12 0]); colormap(jet(15))
    ch = colorbar; set(get(ch,'ylabel'),'string','dB','fontsize',12)
    title(strvcat([datestr(PEcoor.time,'HH:MM dd/mmm') ' UTC '],...
        'Depth Integrated Sound Level',...
        '0 dB Source Level and Cylindrical Spreading Loss Compensated'),'fontsize',14)
    ylabel('Distance (km)','fontsize',12)
    xlabel('Distance (km)','fontsize',12)
    set(gca,'tickdir','out','fontsize',12)
    axis equal; axis tight;
    
    saveSameSize(gcf,'format','png','file',[figuredir,figure_filename])
end