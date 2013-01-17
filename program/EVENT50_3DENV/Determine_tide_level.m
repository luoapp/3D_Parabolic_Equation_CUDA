clear

% Water Depth at WHOI VLA
load WaterdepthVLA.mat

% The tidal levels at WHOI VLA
TIDE.z = WaterDepth.z - WaterDepth.mean;
TIDE.time = WaterDepth.t;

% Bathymetry data from John Goff
load njos_grid.mat
zr = zr + 1.617;  % 1.617 is a constant to shift the zero sea level used in
                  % the bathymetry data to mean tide level. The number is
                  % determined from the raw multi-beam and SW06 shipboard 
                  % data (ask YT for details). 
% meshgrid the bathymetry data
[BATHY_GRID_LON,BATHY_GRID_LAT] = meshgrid(lor,lar);
BATHY_GRID = zr;



% --------------
% Do a test !!
% --------------
VLA_position.latitude = 39+1.2627/60;
VLA_position.longitude = -(73+02.9887/60);

NRL300_position.latitude = 39+10.9574/60;
NRL300_position.longitude = -(72+56.575 /60);

% -------------------------------------------------------------------
% determine the local bathymetry at WHOI VLA from the bathymetry data
% -------------------------------------------------------------------
    % subsample the bathymetry data
    ilor = find(lor>=(VLA_position.longitude-2/60)&lor<=(VLA_position.longitude+2/60));
    ilar = find(lar>=(VLA_position.latitude-2/60)&lar<=(VLA_position.latitude+2/60));
    % convert the longi. lat. coordinate to X-Y coordinate (origine at WHOI VLA)
    [BATHY_GRID_X_GLOBAL,BATHY_GRID_Y_GLOBAL] = ...
        sub_transfer_domain_to_XY(BATHY_GRID_LON(ilar,ilor),BATHY_GRID_LAT(ilar,ilor),VLA_position.latitude,VLA_position.longitude);
    % get the bottom depth at WHOI VLA
    BATHY_GRID_subsampled = BATHY_GRID(ilar,ilor);
    Bathy_at_VLA = griddatan([BATHY_GRID_X_GLOBAL(:) BATHY_GRID_Y_GLOBAL(:)],BATHY_GRID_subsampled(:),[0 0]);

% -----------------------------------------------------------------
% determine the local bathymetry at NRL300 from the bathymetry data
% -----------------------------------------------------------------
    % subsample the bathymetry data
    ilor = find(lor>=(NRL300_position.longitude-2/60)&lor<=(NRL300_position.longitude+2/60));
    ilar = find(lar>=(NRL300_position.latitude-2/60)&lar<=(NRL300_position.latitude+2/60));
    % convert the longi. lat. coordinate to X-Y coordinate (origine at WHOI VLA)
    [BATHY_GRID_X_GLOBAL,BATHY_GRID_Y_GLOBAL] = ...
        sub_transfer_domain_to_XY(BATHY_GRID_LON(ilar,ilor),BATHY_GRID_LAT(ilar,ilor),VLA_position.latitude,VLA_position.longitude);
    % get the bottom depth at WHOI VLA
    BATHY_GRID_subsampled = BATHY_GRID(ilar,ilor);
    [NRL300_X_GLOBAL,NRL300_Y_GLOBAL] = ...
        sub_transfer_domain_to_XY(NRL300_position.longitude,NRL300_position.latitude,VLA_position.latitude,VLA_position.longitude);
    Bathy_at_NRL300 = griddatan([BATHY_GRID_X_GLOBAL(:) BATHY_GRID_Y_GLOBAL(:)],BATHY_GRID_subsampled(:),[NRL300_X_GLOBAL NRL300_Y_GLOBAL]);

% -----------------------------------------------
% estimate the water depth at WHOI VLA and NRL300
% -----------------------------------------------
esti_WD_at_VLA = Bathy_at_VLA + TIDE.z;
esti_WD_at_NRL300 = Bathy_at_NRL300 + TIDE.z;

% ---------------------------------------------------
% compare the water depth measurements and estimates 
% ---------------------------------------------------
figure
subplot(211)
plot(WaterDepth.t-datenum(2005,12,31),WaterDepth.z,TIDE.time-datenum(2005,12,31),esti_WD_at_VLA)
xlabel('Time (day)')
ylabel('Water Depth (m)')
title('Water Depth at WHOI VLA')
legend('Measurements','Estimates')
ylim([70 90])
axis ij

load SSPatNRL300.mat    % water depth, sound speed measurements
subplot(212)
plot(SSPatNRL300.JDVEC-datenum(2005,12,31),SSPatNRL300.WATERDEPTH,TIDE.time-datenum(2005,12,31),esti_WD_at_NRL300)
xlabel('Time (day)')
ylabel('Water Depth (m)')
title('Water Depth at NRL300')
legend('Measurements','Estimates')
ylim([70 90])
axis ij

    
% % NOTE: VLA hydrophone and temerature sensor depths are calculated from the following equation
% SENSOR_DEPTH = esti_WD_at_VLA - SENSOR_HEIGHT;

