function [x y]=sw06_sph2grid3(longitude, latitude)

longitude = abs(longitude);
latitude = abs(latitude);

earth_radius = 6366.707e3;                 %Earth radius

%%define origin
origin_long= (73 + 02.9887/60)/180*pi ; % Shark position (survey)
origin_lat= (39 + 01.2627/60)/180*pi ; % 

%%longitude as x-axis; latitude as y-axis
long_rad=longitude/180*pi;
lat_rad=latitude/180*pi;
y=earth_radius* (lat_rad - origin_lat) ;
x=earth_radius*cos(lat_rad) .* (long_rad - origin_long) ;
x = -x;
