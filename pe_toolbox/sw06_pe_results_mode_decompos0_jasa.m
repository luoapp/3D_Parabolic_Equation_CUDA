clear;
close all;
load ../runSW06_UDELevent50/temp
pe_step_dir = '../mat/pe_step/';
fig_dir = '../figures/mode_coupling/';
figure;set(gcf,'position',[   122   261   747   411]);
for dominant_mode_number = [1: 4]
    pe_step_files = dir(sprintf('%s17Aug06_231500*m%d.mat',pe_step_dir,dominant_mode_number));
    load([pe_step_dir, pe_step_files(1).name]);
    try
        load([kraken_dir,kraken_filename]);
    catch
        kraken_dir = '../mat/kraken_results/';
        kraken_filename = 'kraken_213500.mat';
        load([kraken_dir,kraken_filename]);
    end
    modefunx = interp1(p.Z,p.Psi,-z_short(1:104),'linear','extrap');
    
    % Calculating the mode filtering kernel with the pseudoinverse method ------
    %mode_filtering_kernel_all{ix} = inv(modefunx'*modefunx)*modefunx';
    mode_filtering_kernel = (modefunx'*modefunx)\(modefunx');
    fstep=2;ystep=1;ix1=0;
    ModeAmp = nan(8,floor((size(psifinal_short,2)-1)/ystep)+1,floor((length(pe_step_files)-1)/fstep+1));
    for ix_f = 1:fstep:length(pe_step_files)
        load([pe_step_dir, pe_step_files(ix_f).name]);
        ix1=ix1+1;ix2=0;
        iy = 1:ystep:size(psifinal_short,2);
        %    ix2=ix2+1;
        ModeAmp(:,:,ix1) = mode_filtering_kernel*psifinal_short(1:104,iy);
        
    end
    
    %figure;set(gcf,'position',[ 289   192   724   525]);
%     ax_cb=axes;  set(gca,'position',[0.95 0.1 0.03 0.2],'fontsize',14','fontweight','bold');
    for ix_m=1:4
        %subplot(6,4,dominant_mode_number+4*(ix_m-1))
        axes;
        set(gca,'position',[1/4*(dominant_mode_number-1),1/4*(4-ix_m),1/4-0.01,1/4-0.01]);
        imagesc(x/1000,y/1000,20*log10(abs(squeeze(ModeAmp(ix_m,:,:)))));
        set(gca,'ydir','reverse','fontsize',14,'fontweight','bold')
        %caxis([0 0.1]);
        caxis([-40 -10]);
        set(gca,'xtick',[],'ytick',[]);
        xlabel('');
        ylabel('');
%         xlabel('X(km)');
%         ylabel('Y(km)');
    end
%     pos=get(gca,'position');
%     colorbar(ax_cb,'peer',gca);
%     set(ax_cb,'position',[0.93 pos(2) 0.02 pos(4)]);
%     axes(ax_cb);title('dB');
    
end

    lj_saveSameSize(sprintf('%sMC_%s_m_all',fig_dir,pe_step_files(1).name(1:14)),0);
