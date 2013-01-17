clear
matfiledir = '../mat/vla/';
matfiles = dir( [matfiledir, '*.mat']);
tj = sw06_event50_transmission('j15');
tn = sw06_event50_transmission('nrl300');

for ix_f=1:length(matfiles)
    info = sw06_pe_matfileinfo(matfiles(ix_f).name);
    if info.freq == 300
        for ix1=1:size(tj.time,1)
            if info.time<=tj.time(ix1,2)+1/3600/24 && info.time>=tj.time(ix1,1)-1/3600/24
                matfiles(ix_f).name
            end
        end
    end
    
    
end
