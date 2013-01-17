function sw06_horizontal_mode_coupling_kraken_run_straightline2_func(envdir,envfilename,freqs)
% clear all
% close all
% addpath('../sw06_event50_PE/pe_toolbox/');
% addpath('/Volumes/sw06 working disk/sw06_process_tools/mode_calculation/Georges/SHARP_J15/subroutines')
% envfilename='SW50EVT50_ENV_NRL300_17Aug06_213000';
% envdir='../pe_mode_coupling/mat/env/';
global kraken_filename kraken_dir;
load([envdir,envfilename]);

EV=lj_envfile_para();
trans = sw06_transmission('nrl300');
nMODES0 = 8;
EV.NMODES = nMODES0;
%EV.FREQ = mean(trans.bandwidth);
EV.FREQ = freqs;
EV.ss = TEMPR.gridz';
EV.ss(:,2) = lj_sound_speed(squeeze(TEMPR.temp(floor(length(TEMPR.PEgridy)/2)+1,1,:)),35,TEMPR.gridz.');
EV.depth_of_bottom = BATHY.z(43,1);
if isnan(EV.depth_of_bottom)
    EV.depth_of_bottom = TEMPR.gridz(end);
end
[k, v, p] =sw06_kraken(EV);
ix_nonzeros=find(diff(p.Z));
if length(ix_nonzeros)<length(diff(p.Z))
    ix_nonzeros=[ix_nonzeros;length(p.Z)];
    p.Z=p.Z(ix_nonzeros);
    p.Psi=p.Psi(ix_nonzeros,:);
end
    
p.KH=k;
p.VG=v;
%save(['../pe_mode_coupling/mat/kraken_results/kraken_',envfilename(30:35)],'p');
save(sprintf('%s%s',kraken_dir,kraken_filename),'p');