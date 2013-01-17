clear
close all
envtype='MC';
%envtype='strline';
trans = sw06_event50_transmission('nrl300');
%datadir = sw06_get_filepath( 'sw06_pe_result');
datadir = 'D:\Jing\pe_mode_coupling\runSW06_UDELevent50\mat\moving\thomson\';
datadir = '../mat/pe_result/moving/thomson/';
datadir = '../runSW06_UDELevent50/mat/moving/';
starter = 'thomson';
figuredir = '../figures/topview2/moving/';
shark_vla = sw06_rcvr_config('shark_vla');
figure

if strcmpi(starter, 'thomson')
    files = dir([datadir,'SW50EVT50_event50_3DWAPE_freq_*thomson.mat']);
elseif strcmpi(starter,'modal')
    files=dir(sprintf('%sSW50EVT50_event50_3DWAPE_freq_%d*m%d.mat',datadir,f0,m0));
end

for ix_f = 4%:length(files)
    if files(ix_f).bytes<5e6
        continue;
    elseif ~strcmpi(starter,'thomson')
        if strcmpi(files(ix_f).name(end-10:end),'thomson.mat')
            continue;
        end
    end
    
    
    info = sw06_pe_matfileinfo(files(ix_f).name);
    %     if (info.freq ~= 300) || (info.time~=datenum([2006 8 17 21 30 0]))
    %         continue;
    %     end
    
    if info.freq == 250
        info.source = 'J15';
    else
        info.source = 'NRL300';
    end
    env_figure_filename = sprintf('%sIW/sw06_event50_IW_%s_%s_%s.png',...
        figuredir,info.source,datestr(info.time,'ddmmmyy_HHMMSS'),envtype);
    if ~strcmpi(starter,'thomson')
        pe_figure_filename = sprintf('%ssw06_event50_PE_%s_%dHz_%s_%s_m%d_3.png',...
            figuredir,info.source,info.freq,datestr(info.time,'ddmmmyy_HHMMSS'),envtype,info.mode);
    else
        pe_figure_filename = sprintf('%ssw06_event50_PE_%s_%dHz_%s_%s_thomson.png',...
            figuredir,info.source,info.freq,datestr(info.time,'ddmmmyy_HHMMSS'),envtype);
    end
    %     if ~isempty(dir([figuredir,figure_filename]))
    %         continue;
    %     end
    if info.freq==250
        continue;
        %     elseif info.time<trans.time(3,1) || info.time>trans.time(3,2)
        %         continue;
    end
    load([datadir,files(ix_f).name]);
    %    figure(51); clf
    yplot_max = wid/2*.8;
    yplot_max = 1.5e3;
    set(gcf,'papersize',[11.5 8],'PaperPosition',[0.25 0.25 11 7.5],'PaperPositionMode','auto')
    [xtmp,ytmp]=meshgrid(x,y(abs(y)<=yplot_max));
    rrr=sqrt(xtmp.^2+ytmp.^2);
    %set(gcf,'position',[          1446         660        1434         305]);
    set(gcf,'positio',[106   208   792   479]);
    ax0 = axes;
    set(gca,'fontsize',16,'fontweight','bold');
    TEMPix = abs(TEMPR.PEgridy)<=yplot_max;
    imagesc(TEMPR.PEgridx/1000,TEMPR.PEgridy(TEMPix)/1000,TEMPR.temp(TEMPix,:,6));
    caxis([17 26]);
    %axis equal;
    axis tight;
    xlabel('X(km)');
    ylabel('Y(km)');
    set(gca,'ydir','reverse');
    title([datestr(info.time,'HH:MM:SS'),'GMT'])
    ax3=axes;
    set(gca,'fontweight','bold');
    set(gca,'position',[0.93 0.23 0.014 0.3])
    colorbar(ax3,'peer',ax0);
    set(gca,'fontweight','bold');
    title('^oC','fontweight','bold');
    % lj_saveSameSize(env_figure_filename)
    clf
    
    %    set(gcf,'position',[          1446         660        1434         305]);
    set(gcf,'positio',[106   208   792   479]);
    ax0 = axes;
    set(gca,'fontsize',16,'fontweight','bold');
    imagesc(x/1000,y(abs(y)<=yplot_max)/1000,10*log10(Ez(:,abs(y)<=yplot_max)'.*rrr));
    %axis equal;
    axis tight
    set(gca,'ydir','normal');
    if ~strcmpi(starter,'thomson')
        caxis([0 18]);
        fig_title=([info.source,' freq=',num2str(info.freq),'Hz ',  datestr(info.time,'HH:MM:SS'),' m',num2str(mode_number)]);
    else
        caxis([-20 5]);
        fig_title=([info.source,' freq=',num2str(info.freq),'Hz ',  datestr(info.time,'HH:MM:SS')]);
    end
    %axis equal;
    axis tight;
    xlabel('X(km)');
    ylabel('Y(km)');
    set(gca,'ydir','reverse');
    hold on;
    [C,h]=contour(TEMPR.PEgridx/1000,TEMPR.PEgridy(TEMPix)/1000,TEMPR.temp(TEMPix,:,5),[11: 2: 27 ],'k','linewidth',1);
    set(h,'ShowText','on','TextStep',get(h,'LevelStep')*8)
    title(fig_title);
    ax3=axes;
    set(gca,'fontweight','bold');
    set(gca,'position',[0.93 0.23 0.014 0.3])
    colorbar(ax3,'peer',ax0);
    set(gca,'fontweight','bold');
    title('dB','fontweight','bold');
    lj_saveSameSize(pe_figure_filename)
    %clf
end
