clear
close all
%calculate hla data from pe_result, to be ploted by sw06_pe_plot_hla

sourcename = 'j15';

trans = sw06_event50_transmission(sourcename);

datadir = '../mat/pe_result/';
files = dir([datadir,'SW50EVT50*.mat']);
shark_hla = sw06_rcvr_config('shark_hla');
source = sw06_mooring_position(sourcename);
[source.x source.y] = sw06_sph2grid3(source.LONGITUDE,source.LATITUDE);
for ix=1:size(shark_hla.location,1)
    [shark_hla.x(ix) shark_hla.y(ix)] = sw06_sph2grid3(shark_hla.location(ix,1),...
        shark_hla.location(ix,2));
end

if strcmp(sourcename,'j15')
    f0=250;
    transid = 'M';
elseif strcmp(sourcename,'nrl300')
    f0=300;
    transid = 'F';
end

c0=1500;



for ix_t = 1:size(trans.time,1)
    fprintf('trans #%d\n', ix_t);
    n = 0;
    for ix_f = 1:length(files)
        if files(ix_f).bytes < 50e6
            continue;
        end
        matinfo = sw06_pe_matfileinfo(files(ix_f).name);
        if matinfo.time < trans.time(ix_t,1) || matinfo.time > trans.time(ix_t,2)
            continue;
        end
        if matinfo.freq ~=f0
            warning('wrong f0');
            continue;
        end
        
        n = n+1;
        load([datadir,files(ix_f).name]);
        
        pe.geotime(n)=matinfo.time;
        
        
        if strcmp(sourcename,'j15')
            sx = interp1(source.GMT, source.x, pe.geotime(n));
            sy = interp1(source.GMT, source.y, pe.geotime(n));
        elseif strcmp(sourcename,'nrl300')
            sx = source.x;
            sy = source.y;
        else
            error('unknown source');
        end
        
        shark_hla.z_index = max(find(z<=-max(shark_hla.depth)));
        sl = (sx.^2 + sy.^2).^.5;
        theta1 = atan2(max(shark_hla.y), max(shark_hla.x));
        theta2 = atan2(sy, sx);
        theta = -theta1+theta2;
        shark_hla.dist = (shark_hla.x.^2 + shark_hla.y.^2).^.5;
        shark_hla.newx = max(x)-shark_hla.dist*cos(theta);
        shark_hla.newy = shark_hla.dist*sin(theta);
        newx = linspace(shark_hla.newx(1), shark_hla.newx(end), 100);
        newy = linspace(shark_hla.newy(1), shark_hla.newy(end), 100);
        
        ixx = (x>=min(shark_hla.newx)-10);
        ixy = find((y<=max(shark_hla.newy)+100).* (y>=min(shark_hla.newy)-100));
        [xtmp, ytmp]=meshgrid(x(ixx),y(ixy));
        hla(:,n)=griddata(xtmp', ytmp', Ez_hla(ixx,ixy), newx, newy);
        
        
    end
    
    if n> 0
        save(sprintf('../mat/hla/SW06_PE_%s_%s%d_HLA',sourcename,transid,ix_t), 'source','hla','pe')
        clear hla pe
    end
end
