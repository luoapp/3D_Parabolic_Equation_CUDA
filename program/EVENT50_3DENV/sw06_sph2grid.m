function [x y]=sw06_sph2grid(longitude, latitude)


if min(abs(longitude))<max(abs(latitude))
    t1=latitude;
    latitude=longitude;
    longitude=t1;
end

long_sign=longitude./abs(longitude);
lati_sign=latitude./abs(latitude);

earth_radius = 6366.707e3;                 %Earth radius

%%define origin
origin_long= (73 + 02.9887/60)/180*pi ; % Shark position (survey)
origin_lat= (39 + 01.2627/60)/180*pi ; % 

%%longitude as x-axis; latitude as y-axis
long_rad=abs(longitude)/180*pi;
lat_rad=abs(latitude)/180*pi;
y=earth_radius* (lat_rad - origin_lat) .*long_sign;
x=earth_radius*cos(lat_rad) .* (long_rad - origin_long) .*lati_sign;
