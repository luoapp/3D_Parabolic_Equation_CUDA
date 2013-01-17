clear
close all
sourcename = upper('j15');

trans = sw06_event50_transmission(sourcename);
matdir = '../mat/';
figdir = '../figures/vla/';

datadir = [matdir,'pe_result/'];
savedir = [matdir,'vla/'];

files = dir([datadir,'SW50EVT50*.mat']);
x_axis = datenum([2006 8 17 20 0 0]):5/60/24:datenum([2006 8 17 24 0 0]);

if strcmp(sourcename,'J15')
    f0=250;
    transid = 'M';
elseif strcmp(sourcename,'NRL300')
    f0=300;
    transid = 'F';
end

shark_vla = sw06_rcvr_config('shark_vla');
z1=-[1:1:max(shark_vla.depth)];

for ix_t = [ 2]%1: size(trans.time,1)
    fprintf('ix_t=%d\n',ix_t);
    %     vf=dir([sprintf('%sSW06_PE_%s_%s%d_VLA',figdir,sourcename,transid,ix_t),'.mat']);
    %     f1 = pwd;
    %     if ~isempty(vf) && length(f1)==49
    %         load([sprintf('%sSW06_PE_%s_%s%d_VLA',figdir,sourcename,transid,ix_t),'.mat']);
    %         imagesc(pe.geotime,z1,intens');set(gca,'ydir','normal')
    %         datetick
    %         set(gca,'xtick',x_axis);
    %         set(gca,'xlim',[trans.time(ix_t,1) trans.time(ix_t,2)]);
    %         set(gca,'fontsize',12,'fontweight','bold');
    %         ylabel('depth(m)');
    %         xlabel('Geotime');
    %         title(['Received signal on Shark VLA during J15 M',num2str(ix_t),' transmission']);
    %         print('-dpng',sprintf('%sSW06_PE_%s_%s%d_VLA.png',figdir,sourcename,transid,ix_t))
    %         continue;
    %
    %     end
    n = 0;
    
    for ix_f = 1:length(files)
        matinfo = sw06_pe_matfileinfo(files(ix_f).name);
        if matinfo.time < trans.time(ix_t,1)-5/3600/24 || matinfo.time > trans.time(ix_t,2)+5/3600/24
            continue;
        end
        if matinfo.freq ~=f0
            continue;
        end
        if files(ix_f).bytes<50e6
            continue;
        end
        n = n+1;
        load([datadir,files(ix_f).name]);
        if ~exist('iz_max','var')
            iz_max = find(z>=-max(shark_vla.depth),1,'first');
        end
        pe.geotime(n)=matinfo.time;
        pe.pressure(n,:,:) = psifinal(iz_max:length(z),:);
        
    end
    
    fprintf('%d mat file found\n',n);
    if n > 0
        [pe.geotime ixs] = sort(pe.geotime);
        pe.pressure = pe.pressure(ixs,:,:);
        pe.z = z(iz_max:end);
        pe.y = y;
        save(sprintf('%sSW06_PE_%s_%s%d_VLA',savedir,sourcename,transid,ix_t),'pe');
        clear pe
    end
end
