function [MSEAS_GRID_X_GLOBAL,MSEAS_GRID_Y_GLOBAL] = ...
    sub_transfer_domain_to_XY(MSEAS_GRID_LON,MSEAS_GRID_LAT,src_lat,src_lon)

lat_tmp = [src_lat MSEAS_GRID_LAT(:)'];  
lon_tmp = [src_lon MSEAS_GRID_LON(:)'];
lat0_tmp = ones(size(lat_tmp)) * lat_tmp(1);
lon0_tmp = ones(size(lon_tmp)) * lon_tmp(1);
lat_tmp(2:2:2*length(lat_tmp)) = lat_tmp;
lon_tmp(2:2:2*length(lon_tmp)) = lon_tmp;
lat_tmp(1:2:2*length(lat0_tmp)-1) = lat0_tmp;
lon_tmp(1:2:2*length(lon0_tmp)-1) = lon0_tmp;
[rng,af,ar] = dist(lat_tmp,lon_tmp);
rng = rng(1:2:end); af = af(1:2:end); ar = ar(1:2:end);

MSEAS_GRID_X_GLOBAL = nan(size(MSEAS_GRID_LON));
MSEAS_GRID_Y_GLOBAL = nan(size(MSEAS_GRID_LAT));
MSEAS_GRID_X_GLOBAL(:) = rng(2:end).' .* sin(af(2:end).'/180*pi);
MSEAS_GRID_Y_GLOBAL(:) = rng(2:end).' .* cos(af(2:end).'/180*pi);

return
