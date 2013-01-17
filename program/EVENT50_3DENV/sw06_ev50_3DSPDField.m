function [BATHY, TEMPR, SRC, RCV] = sw06_ev50_3DSPDField(PEcoor,ISOURCE)
% PEcoor.ylim = [-2000 2000];
% PEcoor.zlim = [30 100];
% PEcoor.clim = [10 25];
% PEcoor.dx = 200;
% PEcoor.dy = 100;
% PEcoor.dz = 100;
% PEcoor.plot = 1;
% PEcoor.print = 0;
% PEcoor.plot_radar = 0;
% PEcoor.time = datenum('17-Aug-2006 23:00:00');

if isfield(PEcoor, 'plot') == 0
    PEcoor.plot = 0;
end
if isfield(PEcoor, 'print') == 0
    PEcoor.print = 0;
end

%% sw54 sw32 nrl300
sw54 = sw06_mooring_position(54);
[sw54.x sw54.y]=sw06_sph2grid3(sw54.LONGITUDE,sw54.LATITUDE);
sw54.lag = 0;
PEcoor.xend_long = sw54.LONGITUDE; 
PEcoor.xend_lat = sw54.LATITUDE;
PEcoor.xend_globalx = sw54.x;
PEcoor.xend_globaly = sw54.y;


sw32 = sw06_mooring_position(32);
[sw32.x sw32.y]=sw06_sph2grid3(sw32.LONGITUDE,sw32.LATITUDE);
sw32.x = -sw32.x;
sw32.y = -sw32.y;
sw32.dist = sqrt((sw32.x^2 + sw32.y^2));
sw32.lag = 17.07;

nrl300 = sw06_mooring_position('nrl300');
[nrl300.x nrl300.y] = sw06_sph2grid3(nrl300.LONGITUDE,nrl300.LATITUDE);
nrl300.dist = sqrt((nrl300.x^2 + nrl300.y^2));
nrl300.lag = 30.94;

sharp= sw06_mooring_position('sharp');

%% PEcoor init

[UDelTrack.globalx UDelTrack.globaly] = sw06_sph2grid3(sharp.LONGITUDE,sharp.LATITUDE);

if strcmpi(ISOURCE(1:3),'nrl') == 1,
    PEcoor.org_long = nrl300.LONGITUDE;
    PEcoor.org_lat = nrl300.LATITUDE;
    xlen = nrl300.dist;
    
    warning(' TEMPR.src2rcvdist = nrl300.dist + 2000, changed due to nrl300_memerror!');
    xlen = nrl300.dist +2000;
    
    SRC.globalx = nrl300.x;
    SRC.globaly = nrl300.y;
    PEcoor.org_globalx = nrl300.x;
    PEcoor.org_globaly = nrl300.y;
elseif strcmpi(ISOURCE(1:3),'ude') == 1,
    PEcoor.org_long = interp1(sharp.GMT,sharp.LONGITUDE,PEcoor.time);
    PEcoor.org_lat = interp1(sharp.GMT,sharp.LATITUDE,PEcoor.time);
    [sharp.x sharp.y] = sw06_sph2grid3(PEcoor.org_long,PEcoor.org_lat);
    sharp.x = sharp.x + 200; sharp.y = sharp.y +200;
    sharp.dist = sqrt((sharp.x^2 + sharp.y^2));
    xlen = sharp.dist;
    
    
    warning(' TEMPR.src2rcvdist = sharp.dist + 2000, changed due to J15_memerror!');
    xlen = sharp.dist +2000;
    
    SRC.globalx = sharp.x;
    SRC.globaly = sharp.y;
    PEcoor.org_globalx = sharp.x;
    PEcoor.org_globaly = sharp.y;
end
% determine the x limits
PEcoor.xlim(1) = 0;
PEcoor.xlim(2) = ceil((xlen/PEcoor.dx)+1)*PEcoor.dx;
RCV.globalx = 0;
RCV.globaly = 0;

% 3D Temperature Field
O = sw06_ev50_3denv_func(PEcoor);
TEMPR.globalx = O.global_mesh.x;
TEMPR.globaly = O.global_mesh.y;
TEMPR.temp = permute(O.temp_3d,[2 1 3]);
TEMPR.PEgridx = O.PE_grid.xgrid;
TEMPR.PEgridy = O.PE_grid.ygrid;
TEMPR.gridz = O.PE_grid.zgrid;
TEMPR.src2rcvdist = xlen;

% Bathymetry with tide
BATHY = sw06_bathy_tide_adj_2(PEcoor);

if PEcoor.plot,
    
    figure(59); clf
    set(gcf,'papersize',[11.5 8],'paperposition',[.25 .25 11 7.5])
    subplot(121)    
    [junk,idz] = min(abs(TEMPR.gridz-30));
    pcolor(TEMPR.globalx/1000,TEMPR.globaly/1000,squeeze(TEMPR.temp(:,:,idz)))
    shading flat
    hold on
    plot(UDelTrack.globalx/1000,UDelTrack.globaly/1000,'linewidth',3,'color',[.5 .5 .5])
    text(SRC.globalx/1000,SRC.globaly/1000,'  SRC  ','fontsize',12,'horizontalalignment','left')
    plot(SRC.globalx/1000,SRC.globaly/1000,'kp','markersize',12,'markerfacecolor','k')
    text(RCV.globalx/1000,RCV.globaly/1000,'  WHOI VLA  ','fontsize',12,'horizontalalignment','right')
    plot(RCV.globalx/1000,RCV.globaly/1000,'kd','markersize',12,'markerfacecolor','k')
    plot([SRC.globalx 0]/1000,[SRC.globaly 0]/1000,'r-','linewidth',3)
    axis equal
    axis([-3 12 -3 20])
    set(gca,'tickdir','out','box','on','fontsize',10)
    caxis([10 25])
    ch = colorbar;
    set(get(ch,'ylabel'),'string','Temperature (^oC)','fontsize',12)
    xlabel('Distance E. (km)','fontsize',12)
    ylabel('Distance N. (km)','fontsize',12)
    title(sprintf('Depth = %.2f m, %s',TEMPR.gridz(idz),datestr(PEcoor.time)),'fontsize',16)
    drawnow

    subplot(122)    
    [junk,idz] = min(abs(TEMPR.gridz-30));
    pcolor(TEMPR.globalx/1000,TEMPR.globaly/1000,BATHY.z)
    shading flat
    hold on
    plot(UDelTrack.globalx/1000,UDelTrack.globaly/1000,'linewidth',3,'color',[.5 .5 .5])
    text(SRC.globalx/1000,SRC.globaly/1000,'  SRC  ','fontsize',12,'horizontalalignment','left')
    plot(SRC.globalx/1000,SRC.globaly/1000,'kp','markersize',12,'markerfacecolor','k')
    text(RCV.globalx/1000,RCV.globaly/1000,'  WHOI VLA  ','fontsize',12,'horizontalalignment','right')
    plot(RCV.globalx/1000,RCV.globaly/1000,'kd','markersize',12,'markerfacecolor','k')
    plot([SRC.globalx 0]/1000,[SRC.globaly 0]/1000,'r-','linewidth',3)
    axis equal
    axis([-3 12 -3 20])
    set(gca,'tickdir','out','box','on','fontsize',10)
    caxis([60 90])
    ch = colorbar;
    set(get(ch,'ylabel'),'string','Depth (m)','fontsize',12)
    xlabel('Distance E. (km)','fontsize',12)
    % ylabel('Distance N. (km)','fontsize',12)
    title(sprintf('Bathymetry plus tide %s',datestr(PEcoor.time)),'fontsize',16)
    drawnow
    
end

% keyboard

return