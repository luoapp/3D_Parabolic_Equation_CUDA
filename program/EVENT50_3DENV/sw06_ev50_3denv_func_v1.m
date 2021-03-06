function ret = sw06_ev50_3denv_func(PEcoor)
%curved wave shape
ret.PEcoor = PEcoor;
[ PEcoor.org_x PEcoor.org_y] = sw06_sph2grid3(PEcoor.org_long, PEcoor.org_lat);
x_grid_pe = [PEcoor.xlim(1):PEcoor.dx:PEcoor.xlim(2)];
y_grid_pe = [PEcoor.ylim(1):PEcoor.dy:PEcoor.ylim(2)];
z_grid = [PEcoor.zlim(1):PEcoor.dz:PEcoor.zlim(2)];
if isfield(PEcoor, 'plot') == 0
    PEcoor.plot = 0;
end
if isfield(PEcoor, 'print') == 0
    PEcoor.print = 0;
end

%% RV Sharp, RV Oceanus and transmission time
sharp= sw06_mooring_position('sharp');
[sharp.x sharp.y]=sw06_sph2grid3(sharp.LONGITUDE, sharp.LATITUDE);
trans = sw06_event50_transmission('both');
time_limit = [trans.time(1,1)-1,trans.time(end,2)+1];
oceanus = sw06_mooring_position('oceanus');
[oceanus.x oceanus.y]=sw06_sph2grid3(oceanus.LONGITUDE, oceanus.LATITUDE);

%% sw54 sw32 nrl300
sw54 = sw06_mooring_position(54);
[sw54.x sw54.y]=sw06_sph2grid3(sw54.LONGITUDE,sw54.LATITUDE);
sw54.lag = 0;

sw32 = sw06_mooring_position(32);
[sw32.x sw32.y]=sw06_sph2grid3(sw32.LONGITUDE,sw32.LATITUDE);
sw32.x = -sw32.x;
sw32.y = -sw32.y;
sw32.dist = (sw32.x^2 + sw32.y^2)^0.5;
sw32.lag = 17.07;

nrl300 = sw06_mooring_position('nrl300');
[nrl300.x nrl300.y] = sw06_sph2grid3(nrl300.LONGITUDE,nrl300.LATITUDE);
nrl300.dist = (nrl300.x^2 + nrl300.y^2)^0.5;
nrl300.lag = 30.94;

%% IW dir and spd
IW_dir.sw54 = 51.6978;      %%wave propogation direction
IW_dir.sw32 = 50.4790;
IW_dir.sw32_nrl300 = 58.6952;
IW_dir.sw32_sw54 = 55;
IW_dir.mean = mean([IW_dir.sw54, IW_dir.sw32]);
IW_dir.def = 55;



IW_sp.sw54 = 55.6164;
IW_sp.sw32 = 53.2422;
IW_sp.mean = mean([IW_sp.sw54, IW_sp.sw32]);

%% Thermistor data
thermistor = [45 32 54 ];
top_layer = find(z_grid<15); %define toplayer
for ix = 1:length(thermistor) %
    
    if thermistor(ix) == 32
        load('SSPatSW32.mat');
        mt = SSPatSW32.JDVEC;
        Ti_ = SSPatSW32.T;
        SNDSPD = SSPatSW32.SNDSPD;
        sd = SSPatSW32.SENSOR_DEPTH;
    elseif thermistor(ix) == 54
        load('SSPatSHARK.mat');
        mt = SSPatSHARK.JDVEC;
        Ti_ = SSPatSHARK.T;
        SNDSPD = SSPatSHARK.SNDSPD;
        sd = SSPatSHARK.SENSOR_DEPTH;
    elseif thermistor(ix) == 45
        load('SSPatNRL300.mat');
        mt = SSPatNRL300.JDVEC;
        Ti_ = SSPatNRL300.T;
        SNDSPD = SSPatNRL300.SNDSPD;
        sd = SSPatNRL300.SENSOR_DEPTH;
        
    end
    
    ix1 =max(find(mt<=time_limit(1)));
    ix2 = max(find(mt<=time_limit(2)));
    
    Ti = zeros(length(z_grid),ix2-ix1+1);
    for ix4=ix1:ix2
        Ti(:,ix4-ix1+1) = interp1(sd(:,ix4),Ti_(:,ix4),z_grid,'linear','extrap');
        Ti(top_layer, ix4-ix1+1)= Ti(max(top_layer),ix4-ix1+1);  %assuming top layer is well mixed
    end
    
    if thermistor(ix) ==32
        sw32.time_interp= mt(ix1:ix2);
        sw32.temp_interp (:,:)=Ti;
        sw32.depth_interp = z_grid;
    elseif thermistor(ix) == 54
        sw54.time_interp= mt(ix1:ix2);
        sw54.temp_interp (:,:)=Ti;
        sw54.depth_interp = z_grid;
    elseif thermistor(ix) == 45
        nrl300.time_interp= mt(ix1:ix2);
        nrl300.temp_interp (:,:)=Ti;
        nrl300.depth_interp = z_grid;
    end
end

theta_nrl300_sw54 = -62.8510/180*pi; %nrl300 - sw54
PEcoor.org_x_pe = PEcoor.org_x .* cos(theta_nrl300_sw54) - PEcoor.org_y.*sin(theta_nrl300_sw54);
PEcoor.org_y_pe = PEcoor.org_x .* sin(theta_nrl300_sw54) + PEcoor.org_y.*cos(theta_nrl300_sw54);
PEcoor.org_theta_to_PE = atan2(PEcoor.org_y_pe, PEcoor.org_x_pe);
PEcoor.org_global_theta = atan2(PEcoor.org_y, PEcoor.org_x);
PEcoor.dist = (PEcoor.org_x^2 + PEcoor.org_y^2)^0.5;

x_grid = - x_grid_pe  + PEcoor.dist;
y_grid = - y_grid_pe;

[newgrid_x newgrid_y] = meshgrid(x_grid,y_grid);
IN.theta = PEcoor.org_global_theta;
IN.x = newgrid_x;
IN.y = newgrid_y;
global_mesh = sw06_ev50_coor_trans(IN);

temp_3d = zeros(length(x_grid), length(y_grid), length(z_grid));

PEcoor.theta1 = atan2(nrl300.y-sw54.y, nrl300.x-sw54.x)-IW_dir.sw32_sw54/180*pi;
PEcoor.theta1 = asin(sw32.lag*IW_sp.mean/sw32.dist);

sw32.x_in_PE1 = sw32.dist*cos(PEcoor.theta1);
sw54.x_in_PE = 0;

PEcoor.theta2 = atan2(nrl300.y-sw54.y, nrl300.x-sw54.x)-IW_dir.sw32_nrl300/180*pi;
PEcoor.theta2 = asin(nrl300.lag*IW_sp.mean/nrl300.dist);

sw32.x_in_PE2 = sw32.dist*cos(PEcoor.theta2);
nrl300.x_in_PE = nrl300.dist*cos(PEcoor.theta2);

PEcoor.theta = PEcoor.theta1;

for ix_z =1:length(z_grid)
    ix_z
    ix32 = find(sw32.depth_interp==z_grid(ix_z));
    ix54 = find(sw54.depth_interp==z_grid(ix_z));
    ix45 = find(nrl300.depth_interp==z_grid(ix_z));
    for ix_x = 1:length(x_grid)
        for ix_y = 1:length(y_grid)
            
            IN.x = x_grid(ix_x);
            IN.y = y_grid(ix_y);
            IN.theta = PEcoor.org_theta_to_PE+PEcoor.theta1;
            
            O=sw06_ev50_coor_trans(IN);
            
            if O.x < sw32.x_in_PE2
                sw32.x_in_PE = sw32.x_in_PE1;
                mooring1 = sw32;
                mooring2 = sw54;
                ix_moor1 = ix32;
                ix_moor2 = ix54;
                IN.theta = PEcoor.theta1;
                O.y = O.y + sw32.dist * sw06_IW_waveshape(O.x/sw32.dist,PEcoor.time);
            else
                sw32.x_in_PE = sw32.x_in_PE2;
                mooring1 = nrl300;
                mooring2 = sw32;
                ix_moor1 = ix45;
                ix_moor2 = ix32;
                IN.theta = PEcoor.org_theta_to_PE+PEcoor.theta2;
                IN.y = IN.y + sw32.dist*sin( PEcoor.theta1 - PEcoor.theta2);
                O=sw06_ev50_coor_trans(IN);
            end
            
            t1 = interp1(mooring1.time_interp,mooring1.temp_interp(ix_moor1,:),...
                PEcoor.time-O.y/IW_sp.mean/60/24+mooring1.lag/60/24); %
            t2 = interp1(mooring2.time_interp,mooring2.temp_interp(ix_moor2,:),...
                PEcoor.time-O.y/IW_sp.mean/60/24+mooring2.lag/60/24);
            
            temp_3d(ix_x,ix_y,ix_z)=interp1([mooring2.x_in_PE mooring1.x_in_PE], [t2 t1], O.x, 'linear','extrap');
        end
    end
    
    %% plot
    if PEcoor.plot
        
        J15 = sw06_J15_YTcoor(PEcoor.time);
        J15.theta_to_PE = atan2(J15.PEcoor.y, J15.PEcoor.x);
        J15.global_theta = atan2(J15.Earthcor.y, J15.Earthcor.x);
        J15.dist = (J15.PEcoor.x ^ 2 + J15.PEcoor.y ^ 2)^0.5;

        figure
        hold on
        pcolor(global_mesh.x/1000, global_mesh.y/1000, squeeze(temp_3d(:,:,ix_z))')
        axis([-3 10 -4 20])
        shading flat
        %set(gca,'dataaspectratio',[1 1 1]);
        
        if PEcoor.plot_radar
            %% radar
            sharp.radar = sw06_radarimage2(PEcoor.time,'sharp');
            [ sharp.radar.xmesh sharp.radar.ymesh] = ...
                meshgrid(sharp.radar.x_grid,sharp.radar.y_grid);
            sharp.handle = pcolor((J15.Earthcor.x+sharp.radar.xmesh)/1000, (J15.Earthcor.y+sharp.radar.ymesh)/1000,...
                ones(size(sharp.radar.mask(end:-1:1,:))));
            shading flat;
            set(sharp.handle, 'facealpha','flat','alphaData', sharp.radar.mask(end:-1:1,:)*0.7);
            
            
            ox = interp1(oceanus.GMT, oceanus.x, PEcoor.time);
            oy = interp1(oceanus.GMT, oceanus.y, PEcoor.time);
            oceanus.radar = sw06_radarimage2(PEcoor.time, 'oceanus');
            [ oceanus.radar.xmesh oceanus.radar.ymesh] = ...
                meshgrid(oceanus.radar.x_grid,oceanus.radar.y_grid);
            oceanus.handle = pcolor(ox/1000+oceanus.radar.xmesh/1000, oy/1000+oceanus.radar.ymesh/1000,...
                ones(size(oceanus.radar.mask(end:-1:1,:))));
            shading flat;
            set(oceanus.handle, 'facealpha','flat','alphaData', oceanus.radar.mask(end:-1:1,:));
        end
        %%
        axis equal
        xlabel('Distance (km)','fontweight','bold');
        ylabel('Distance (km)','fontweight','bold');
        hold on
        %plot(sharp.x/1000,sharp.y/1000,'linewidth',3,'color',[.5 .5 .5])
        plot(sharp.x/1000,sharp.y/1000,'linewidth',2,'color','b')
        %text_rvsharp = text(J15.Earthcor.x/1000,J15.Earthcor.y/1000,'  R/V Sharp  ','fontsize',12,'horizontalalignment','left')
        plot(J15.Earthcor.x/1000, J15.Earthcor.y/1000, 'k^','markersize',5,'markerfacecolor','r');
        text(sw54.x/1000,sw54.y/1000,' VLA  ','fontsize',12,'fontweight','bold','horizontalalignment','right')
        plot(sw54.x/1000,sw54.y/1000,'kd','markersize',8,'markerfacecolor','r')
        text(nrl300.x/1000,nrl300.y/1000,'  NRL300  ','fontsize',12,'fontweight','bold','horizontalalignment','right')
        plot(nrl300.x/1000,nrl300.y/1000,'kd','markersize',6,'markerfacecolor','r')
        
        caxis(PEcoor.clim);
        grid on;
        ax1 = gca;
        ax_c = colorbar;
        axes(ax_c);
        title('^oC','fontweight','bold');
        axes(ax1);
        title(['J15 D=',num2str(z_grid(ix_z)), ' ',datestr(PEcoor.time)]);
        if PEcoor.print
            pix_name = sprintf('sw06_Tempr_Depth%dm_%s_radar2.png',fix(z_grid(ix_z)),datestr(PEcoor.time,'yyyymmmdd_HHMMSS'));
            print(gcf,'-dpng',pix_name)
            %close(gcf)
        end
    end
    %%
end

ret.temp_3d = temp_3d;
ret.global_mesh =global_mesh;
ret.PE_grid.xgrid = x_grid_pe;
ret.PE_grid.ygrid = y_grid_pe;
ret.PE_grid.zgrid = z_grid;


return
