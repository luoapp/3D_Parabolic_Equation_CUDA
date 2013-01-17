clear
close all

mode_number=4;

spec_filename=sprintf('sw06_pe_plot_spec_broadband_moving_m%d.mat',mode_number);

if exist(spec_filename,'file')
    load(spec_filename);
else
    %envtype='curved';
    envtype='strline';
    
    trans = sw06_event50_transmission('nrl300');
    f0=300;
    %datadir = sw06_get_filepath( 'sw06_pe_result');
    %datadir = '../runSW06_UDELevent50/mat/moving/';
    datadir = sprintf('../mat/pe_result/moving/m%d/',mode_number);
    %datadir2 ='../mat_singleFreq/pe_result/';
    
    figuredir = '../figures/spec/moving/';
    shark_vla = sw06_rcvr_config('vla_effective');
    delay = 0;
    F_ix = 3;
    geotime = trans.time(F_ix,1);
    %geotime = datenum([2006 8 17 21 55 0]);
    rcvr_array=sw06_rcvr_config('vla_effective');
    phone_depth = rcvr_array.depth;
    
    duration_sec=0:10:480;
    freq=[270:2:330];
    psi2=zeros(length(phone_depth),length(duration_sec), length(freq),2048);
    for ix_sec = 1:length(duration_sec)
        sec_number = duration_sec(ix_sec);
        
        for ix_freq = 1:length(freq)
            file=dir(sprintf('%s*freq_%d_%s_m%d.mat',...
                datadir,freq(ix_freq),datestr(geotime+sec_number/3600/24,'ddmmmyy_HHMMSS'),...
                mode_number));
            load([datadir,file.name],'psifinal','z','y');
            info = sw06_pe_matfileinfo(file.name);
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
            
            %[~,ixy]=min(abs(y-rcv_y));
            
            if ix_freq ==1
                for ix3=1:length(phone_depth)
                    phone_index(ix3) = find(z<=-phone_depth(ix3),1,'last');
                end
                
            end
            psi2(:,ix_sec,ix_freq,:) = psifinal(phone_index,:);
            
            
            clear psifinal
        end
    end
    save(spec_filename);
end

figure
set(gcf,'position',[ 120   238     1005         455]);
ix_f = 1:2:61;
for rcv_y = -700
    [~,ixy]=min(abs(y-rcv_y));
    
    for ix=1:length(phone_depth)
        
        pcolor(duration_sec/60,freq,20*log10(abs(squeeze(psi2(ix,:,:,ixy)))'))
        axcb = colorbar;
        shading interp
        caxis([-60 -42])
        set(gca,'xlim',[0 duration_sec(end)/60]);
        set(gca,'ydir','normal','fontsize',12,'fontweight','bold')
        %set(gca,'xticklabel',{'21:30','','21:32','','21:34','','21:36','',})
        xlabel('Geotime (min)','fontsize',14,'fontweight','bold')
        ylabel('Freq (Hz)','fontsize',14,'fontweight','bold')
        title(['Spectrum of F',num2str(F_ix),' based on PE model of',datestr(geotime),' @[y,z]=[',num2str(rcv_y),...
            ',',num2str(phone_depth(ix)),'] mode',num2str(mode_number)]);
        filename = sprintf('%ssw06_PE_spec_F%d_%s_D%d_m%d_moving',figuredir,F_ix,datestr(geotime,'ddmmmyy_HHMMSS'),ix,mode_number);
        axc=gca;
        axes(axcb);
        title('dB');
        axes(axc);
        %pause
        lj_saveSameSize(filename)
        clf
    end
end