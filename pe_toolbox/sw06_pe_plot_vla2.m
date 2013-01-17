clear
close all
sourcename = upper('nrl300');

trans = sw06_event50_transmission(sourcename);
datadir = '../mat/vla/';
figdir = '../figures/vla/';

datadir = '../mat/pe_result/';

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
for ix_t = 4%1: size(trans.time,1)
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
        n = n+1;
        load([datadir,files(ix_f).name]);
        pe.geotime(n)=matinfo.time;
        t1 = 20*log10(abs(psifinal(1:length(z),length(y)/2)));
        pe.intens(n,:) = interp1(z, t1, z1);
    end
    
    fprintf('%d mat file found\n',n);
    if n > 0
        [gt ixs] = sort(pe.geotime);
        intens = pe.intens(ixs,:);
        %save(sprintf('%sSW06_PE_%s_%s%d_VLA',figdir,sourcename,transid,ix_t),'intens','pe');
        clear pe intens
    end
end
