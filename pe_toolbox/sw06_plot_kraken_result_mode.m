clear;close;
timestr = '214330';
f0=330;
try
    load(sprintf('../mat/kraken_results/kraken_%s_f%d.mat',timestr,f0));
catch
    load(['../mat/kraken_results/kraken_',timestr,'.mat'])
end
for ix_m=1:8
    subplot(1,8,ix_m)
    plot(p.Psi(:,ix_m),p.Z);
    axis([-0.25 0.25 0 100]);
    set(gca,'ydir','reverse');
    ylabel('Depth (m)');
end
lj_saveSameSize(['../figures/kraken/kraken_results_',timestr])

figure;set(gcf,'position',[ 360   263   640   435]);hold on;
timestr = '213000';
load(['../mat/kraken_results/kraken_',timestr,'.mat'])
for ix_m=1:3
    plot(p.Psi(:,ix_m)*1.5+ix_m,p.Z);
end
timestr2='214000';
load(['../mat/kraken_results/kraken_',timestr2,'.mat'])
for ix_m=1:3
    plot(p.Psi(:,ix_m)*1.5+ix_m,p.Z,'--');
end
set(gca,'ydir','reverse','ylim',[0 100],'xlim',[0.5 3.5],'xtick',[1 2 3]);
set(gca,'fontsize',14,'fontweight','bold');
ylabel('Depth (m)');xlabel('Mode number');box on;
lj_saveSameSize(['../figures/kraken/kraken_results_',timestr,'_',timestr2])

figure;set(gcf,'position',[ 70   263   268   435]);hold on
%plot(squeeze(TEMPR.temp(1,1,:)),TEMPR.gridz)
%plot(squeeze(TEMPR.temp(54,1,:)),TEMPR.gridz,'--')
plot(lj_sound_speed(squeeze(TEMPR.temp(1,1,:)),35,TEMPR.gridz.'),TEMPR.gridz)
plot(lj_sound_speed(squeeze(TEMPR.temp(54,1,:)),35,TEMPR.gridz.'),TEMPR.gridz,'--')
set(gca,'ydir','reverse','ylim',[0 100],'xlim',[1490 1535]);
set(gca,'fontsize',14,'fontweight','bold');
ylabel('Depth (m)');xlabel('Sound speed (m/s)');box on;
lj_saveSameSize(['../figures/kraken/ssp_',timestr,'_',timestr2])

