clear
close all
 
envtype='curved';
%envtype='strline';

trans = sw06_event50_transmission('udel');
f0=300;
%datadir = sw06_get_filepath( 'sw06_pe_result');
datadir = '..\mat\pe_result\';
%datadir = 'D:\Jing\matlib\bin\';
files = dir([datadir,'SW50EVT50_event50_3DWAPE_freq_250_17Aug06_*.mat']);
envfiledir = '..\mat\env\';
cudafiledir = '..\mat\cuda\';
figuredir = '..\m4\figures\';
shark_vla = sw06_rcvr_config('shark_vla');
figure
set(gcf,'visible','on');

for ix_f = 1:length(files)
    if files(ix_f).bytes<10e6
        continue;
    end
    
    info = sw06_pe_matfileinfo([files(ix_f).name(1:end-11),'.mat']);
    if info.freq == 250
        info.source = 'UDelJ15';
    else
        info.source = 'NRL300';
    end
    
    
    
    envfilename = sprintf('%sIW_ENV_UDelJ15%s',envfiledir,...
        files(ix_f).name(end-25:end));
    
%     if info.time ~= datenum([2006 08 17 21 34 0]);
%         continue;
%     end
    
    try
        load(envfilename);
    catch
        continue;
    end
    
    
    cuda_filename = [cudafiledir,'freq',num2str(info.freq),  files(ix_f).name(end-25:end-4),'_cuda.mat'];
    load(cuda_filename);
    
    env_figure_filename = sprintf('%sIW/sw06_event50_IW_%s_%s_%s.png',...
        figuredir,info.source,datestr(info.time,'ddmmmyy_HHMMSS'),envtype);
    pe_figure_filename = sprintf('%stopview2/sw06_event50_PE_%s_%s_FREQ%d_%s_cuda.png',...
        figuredir,info.source,datestr(info.time,'ddmmmyy_HHMMSS'),info.freq,envtype);
    
    %     if ~isempty(dir([figuredir,figure_filename]))
    %         continue;
    %     end
    
    %     if info.freq==250
    %         continue;
    %     elseif info.time<trans.time(3,1) || info.time>trans.time(3,2)
    %         continue;
    %     end
    
    
    load(ssp3dfield_filename);
    load([datadir,files(ix_f).name]);
    
    
    try
        Ez = real(Ez);
    catch
        Ez = real(mat2c);
    end
    
    lambda=c0/freq ;
    dx=steplength;
    dy=wid/ny;
    dz=wid/aspect/nz;
    y=(-0.5*ny*dy):dy:(0.5*ny*dy)-dy;
    z=(-0.5*nz*dz):dz:(0.5*nz*dz)-dz;
    [Y,Z]=meshgrid(y,z);
    Ly=max(y)-min(y);
    Lz=max(z)-min(z);
    x=[0 (ndxout:ndxout:numstep)*steplength];
    
    %    figure(51); clf
    yplot_max = wid/2*.8;
    yplot_max = 1.4e3;
    set(gcf,'papersize',[11.5 8],'PaperPosition',[0.25 0.25 11 7.5],'PaperPositionMode','auto')
    [xtmp,ytmp]=meshgrid(x,y(abs(y)<=yplot_max));
    rrr=sqrt(xtmp.^2+ytmp.^2);
    
    
    set(gcf,'position',[          1         660        1434         305]);
    ax0 = axes;
    set(gca,'fontsize',16,'fontweight','bold');
    TEMPix = abs(TEMPR.PEgridy)<=yplot_max;
    imagesc(TEMPR.PEgridx/1000,TEMPR.PEgridy(TEMPix)/1000,TEMPR.temp(TEMPix,:,4));
    caxis([17 26]);
    axis equal; axis tight;
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
    lj_saveSameSize(env_figure_filename)
    clf
    
    set(gcf,'position',[          1         660        1434         305]);
    ax0 = axes;
    set(gca,'fontsize',16,'fontweight','bold');
    imagesc(x/1000,y(abs(y)<=yplot_max)/1000,10*log10(Ez(:,abs(y)<=yplot_max)'.*rrr));
    axis equal; axis tight
    set(gca,'ydir','normal');
    caxis([-20 5]);
    axis equal; axis tight;
    xlabel('X(km)');
    ylabel('Y(km)');
    set(gca,'ydir','reverse');
    hold on;
    contour(TEMPR.PEgridx/1000,TEMPR.PEgridy(TEMPix)/1000,TEMPR.temp(TEMPix,:,4),[21.2 23 24 25.5 ],'r','linewidth',1);
    title([datestr(info.time,'HH:MM:SS'),'GMT Freq=',num2str(info.freq)])
    ax3=axes;
    set(gca,'fontweight','bold');
    set(gca,'position',[0.93 0.23 0.014 0.3])
    colorbar(ax3,'peer',ax0);
    set(gca,'fontweight','bold');
    title('dB','fontweight','bold');
    
    lj_saveSameSize(pe_figure_filename)
    clf
    
 
end