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

temp_3d = zeros(length(x_grid), length(y_grid), length(z_grid));
for ix_z =1:length(z_grid)
    [x1 y1] = meshgrid(x_grid, y_grid);
    if ix_z == 1
        
        theta = PEcoor.org_theta_to_PE+PEcoor.theta1;
        c = cos(theta);
        s = sin(theta);
        x2 = c*x1 - s*y1;
        y2 = s*x1 + c*y1;
        y3 = y2;
        for ix3=1:size(x2,1)
            for ix4=1:size(x2,2)
                y3(ix3,ix4) = y2(ix3,ix4) + ...
                    sw32.dist * sw06_IW_waveshape(x2(ix3,ix4)/sw32.dist,PEcoor.time);
            end
        end
        y41 = PEcoor.time-y3/IW_sp.mean/60/24;
        
        theta = PEcoor.org_theta_to_PE+PEcoor.theta2;
        [x1 y1] = meshgrid(x_grid, y_grid);
        y1 = y1 + sw32.dist*sin( PEcoor.theta1 - PEcoor.theta2);
        c = cos(theta);
        s = sin(theta);
        x2 = c*x1 - s*y1;
        y2 = s*x1 + c*y1;
        y42 = PEcoor.time-y2/IW_sp.mean/60/24;
    end
    
    interp_t1 = interp1(sw32.time_interp,sw32.temp_interp(ix_z,:),...
        sw32.time_interp + (sw32.lag-0)/60/24);
    Y = sw32.time_interp-0;
    T=[sw54.temp_interp(ix_z,:);interp_t1];
    X = [sw54.x_in_PE sw32.x_in_PE1];
    t3di=interp2(X, Y, T', x2,y41);
    
    interp_t1 = interp1(nrl300.time_interp,nrl300.temp_interp(ix_z,:),...
        nrl300.time_interp + (nrl300.lag-sw32.lag)/60/24);
    Y = nrl300.time_interp-sw32.lag/60/24;
    T=[sw32.temp_interp(ix_z,:);interp_t1];
    X = [sw32.x_in_PE2 nrl300.x_in_PE];
    t3di2=interp2(X, Y, T', x2,y42);
    
    t5=find(x2<sw32.x_in_PE2);
    t3di2(t5)=t3di(t5);
    
    for ix3= 1:size(t3di2,1)
        t1 = find(isnan(t3di2(ix3,:)));
        if isempty(t1)
            continue;
        end
        t2 = find(~isnan(t3di2(ix3,:)));
        t3di2(ix3,t1) = interp1(x_grid(t2),t3di2(ix3,t2),x_grid(t1),'linear','extrap');
    end
    %figure(1);imagesc(t3di2)
    temp_3d(:,:,ix_z) = t3di2';
    
end

ret.temp_3d = temp_3d;
ret.global_mesh =global_mesh;
ret.PE_grid.xgrid = x_grid_pe;
ret.PE_grid.ygrid = y_grid_pe;
ret.PE_grid.zgrid = z_grid;


return
