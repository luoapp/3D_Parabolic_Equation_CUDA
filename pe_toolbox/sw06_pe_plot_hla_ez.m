clear
close all
sourcename = 'nrl300';

trans = sw06_event50_transmission(sourcename);

datadir = '../mat/vla/';
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



for ix_t = 3
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
            sy = source.y
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
        
        %y_lim = 300;
        %x_lim = 8500;
        %[xtmp,ytmp]=meshgrid(x(x>x_lim),y(abs(y)<=y_lim));
        %hla(:,n)=griddata(xtmp', ytmp', Ez_hla(x>x_lim,abs(y)<=y_lim), shark_hla.newx, shark_hla.newy);
        
        ixx = (x>=min(shark_hla.newx)-10);
        ixy = find((y<=max(shark_hla.newy)+100).* (y>=min(shark_hla.newy)-100));
        [xtmp, ytmp]=meshgrid(x(ixx),y(ixy));
        hla(:,n)=griddata(xtmp', ytmp', Ez_hla(ixx,ixy), newx, newy);
        
        
    end
    
    [xt2, yt2] = meshgrid((pe.geotime-min(pe.geotime))*24*60,...
        linspace(shark_hla.dist(1), shark_hla.dist(end), 100));
    pcolor(xt2,yt2,10*log10(hla))
    box on;
    set(gca,'ydir','reverse');
    shading flat
    
    % x1=x(ixx);
    % y1=y(ixy);
    % imagesc((pe.geotime-min(pe.geotime))*24*60,shark_hla.dist,log10(hla))
    %caxis([-90 -50])
    %datetick
    axis tight
    set(gca,'fontsize',20);
    title(sprintf('Received signal on HLA during %s%d (model)',transid,ix_t))
    xlabel('Geotime(min)');
    ylabel('Dist. to Shark VLA (m)');
    colorbar
    print('-dpng',sprintf('SW06_PE_%s_%s%d_HLA.png',sourcename,transid,ix_t))
    save(sprintf('../mat/hla/SW06_PE_%s_%s%d_HLA',sourcename,transid,ix_t), 'source','hla','pe')
end
