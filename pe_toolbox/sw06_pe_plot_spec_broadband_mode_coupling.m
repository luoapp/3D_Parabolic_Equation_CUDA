clear
close all

mode_number=5;
mc_filename=sprintf('sw06_pe_plot_spec_broadband_m%d.mat',mode_number);

if exist(mc_filename,'file')
    load(mc_filename);
else
    %envtype='curved';
    envtype='strline';
    
    trans = sw06_event50_transmission('nrl300');
    f0=300;
    %datadir = sw06_get_filepath( 'sw06_pe_result');
    datadir = '../mat/pe_result/';
    %datadir2 ='../mat_singleFreq/pe_result/';
    
    figuredir = '../figures/spec/';
    shark_vla = sw06_rcvr_config('vla_effective');
    ix_freq = 1;
    delay = 0;
    F_ix = 3;
    geotime = trans.time(F_ix,1)+delay/60/24;
    geotime = datenum([2006 8 17 21 55 0]);
    rcvr_array=sw06_rcvr_config('vla_effective');
    phone_depth = rcvr_array.depth;
    files=dir(sprintf('%s*%s_m%d.mat',datadir,...
        datestr(geotime,'ddmmmyy_HHMMSS'),mode_number));
    
    for ix_f = 1:length(files)
        if files(ix_f).bytes<1e6
            continue;
        end
        
        info = sw06_pe_matfileinfo(files(ix_f).name);
        if info.freq == 250
            info.source = 'J15';
            continue;
        else
            info.source = 'NRL300';
        end
        
        %     if abs(info.time - geotime)*24*3600>5
        %         continue;
        %     end
        
        env_figure_filename = sprintf('%sIW/sw06_event50_IW_%s_%s_%s.png',...
            figuredir,info.source,datestr(info.time,'ddmmmyy_HHMMSS'),envtype);
        pe_figure_filename = sprintf('%stopview2/sw06_event50_PE_%s_%dHz_%s_%s.png',...
            figuredir,info.source,info.freq,datestr(info.time,'ddmmmyy_HHMMSS'),envtype);
        
        %     if ~isempty(dir([figuredir,figure_filename]))
        %         continue;
        %     end
        
        %     if info.freq==250
        %         continue;
        %     elseif info.time<trans.time(3,1) || info.time>trans.time(3,2)
        %         continue;
        %     end
        
        load([datadir,files(ix_f).name],'psifinal','y','z');
        if ix_freq ==1
            psi2=zeros(length(phone_depth),size(psifinal,2), length(files));
            for ix3=1:length(phone_depth)
                phone_index(ix3) = find(z<=-phone_depth(ix3),1,'last');
            end
            
        end
        psi2(:,:,ix_freq) = psifinal(phone_index,:);
        freq(ix_freq) = info.freq;
        ix_freq = ix_freq + 1;
        clear psifinal
    end
    [freq, ix]=sort(freq);
    psi2=psi2(:,:,ix);
    ix_f=[1:1:length(freq)];
    save(mc_filename);
end

figure
set(gcf,'position',[ 120   238     1005         455]);
ix_f = 1:3:61;
for ix=1:length(phone_depth)
    
    pcolor(y/0.8/60,freq(ix_f),20*log10(abs(squeeze(psi2(ix,:,ix_f)))'))
    axcb = colorbar;
    shading interp
    caxis([-4 -1.5]*20)
    set(gca,'xlim',[-15 15]);
    %     if F_ix == 3
    %         set(gca,'xlim',[2 9]-delay);
    %     elseif F_ix == 4
    %         set(gca,'xlim',[-600 200]/0.8/60-delay)
    %     end
    set(gca,'ydir','normal','fontsize',12,'fontweight','bold')
    %set(gca,'xticklabel',{'21:30','','21:32','','21:34','','21:36','',})
    xlabel('Geotime (min)','fontsize',14,'fontweight','bold')
    ylabel('Freq (Hz)','fontsize',14,'fontweight','bold')
    title(['Spectrum of F',num2str(F_ix),' based on PE model of',datestr(geotime),' @',num2str(phone_depth(ix)),'m'...
        ' mode',num2str(mode_number)]);
    filename = sprintf('%ssw06_PE_spec_F%d_%s_D%d_m%d_less2',figuredir,F_ix,datestr(geotime,'ddmmmyy_HHMMSS'),ix,mode_number);
    axc=gca;
    axes(axcb);
    title('dB');
    axes(axc);
    lj_saveSameSize(filename)
    clf
end