function BATHY = sw06_bathy_tide_adj_2(YTcor)
%sw06 bathy data with tida level adjusted

if isfield(YTcor, 'xend_globalx') == 0
    YTcor.xend_globalx = 0;
end

if isfield(YTcor, 'xend_globaly') == 0
    YTcor.xend_globaly = 0;
end

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

[x1 y1] = sw06_sph2grid(lor,mean(lar)*ones(size(lor)));
[x2 y2] = sw06_sph2grid(ones(size(lar))*mean(lor),lar);

tide_level = interp1(TIDE.time,TIDE.z,YTcor.time);
x_grid = [YTcor.xlim(1):YTcor.dx:YTcor.xlim(2)];
y_grid = [YTcor.ylim(1):YTcor.dy:YTcor.ylim(2)];
[newgrid_x newgrid_y] = meshgrid(x_grid,y_grid);

IN.theta = atan2(YTcor.xend_globaly-YTcor.org_globaly, YTcor.xend_globalx-YTcor.org_globalx);
IN.x = newgrid_x;
IN.y = newgrid_y;
O1 = sw06_ev50_coor_trans(IN,YTcor);


xm1 = min(min(O1.x));
xm2 = max(max(O1.x));
ym1 = min(min(O1.y));
ym2 = max(max(O1.y));
ix1 = min(find(x1>=xm1));
ix2 = max(find(x1<=xm2)); 
iy1 = min(find(y2>=ym1));
iy2 = max(find(y2<=ym2)); 
[gx gy] = meshgrid(x1(ix1:ix2), y2(iy1:iy2));
gzr = zr(iy1:iy2, ix1:ix2);
nz = griddata(gx,gy,gzr,O1.x,O1.y);
% IN.theta = -atan2(YTcor.xend_globaly-YTcor.org_globaly, YTcor.xend_globalx-YTcor.org_globalx);
% IN.x = gx;
% IN.y = gy;
% Org.org_globalx = -YTcor.org_globalx;
% Org.org_globaly = -YTcor.org_globaly;
% O = sw06_ev50_coor_trans(IN,Org);
% nz = griddata(O.x,O.y,gzr,newgrid_x,newgrid_y);
new_z = zeros(size(nz,1), size(nz,2), length(YTcor.time));
for ix =1 :length(YTcor.time)
    new_z(:,:,ix) = nz + tide_level(ix);
end

BATHY.x = newgrid_x;
BATHY.y = newgrid_y;
BATHY.z = new_z;
BATHY.time = YTcor.time;

return


function [x y]=sw06_sph2grid(longitude, latitude)


if min(abs(longitude))<max(abs(latitude))
    t1=latitude;
    latitude=longitude;
    longitude=t1;
end

earth_radius = 6366.707e3;                 %Earth radius

%%define origin
origin_long = -(73 + 02.9887/60)/180*pi ; % Shark position (survey)
origin_lat = (39 + 01.2627/60)/180*pi ; % 

%%longitude as x-axis; latitude as y-axis
long_rad = longitude/180*pi;
lat_rad = latitude/180*pi;
y = earth_radius * (lat_rad - origin_lat);
x = earth_radius * cos(lat_rad) .* (long_rad - origin_long);

% long_sign=longitude./abs(longitude);
% lati_sign=latitude./abs(latitude);
% 
% earth_radius = 6366.707e3;                 %Earth radius
% 
% %%define origin
% origin_long= (73 + 02.9887/60)/180*pi ; % Shark position (survey)
% origin_lat= (39 + 01.2627/60)/180*pi ; % 
% 
% %%longitude as x-axis; latitude as y-axis
% long_rad=abs(longitude)/180*pi;
% lat_rad=abs(latitude)/180*pi;
% y=earth_radius* (lat_rad - origin_lat) .*long_sign;
% x=earth_radius*cos(lat_rad) .* (long_rad - origin_long) .*lati_sign;

return

function O= sw06_ev50_coor_trans(in,YTcor)
%transform to the IW coordinate
%1)rotate 2)translate
persistent theta c s;
origin = [ 0 0]; %shark VLA
%O.coor = [cos(in.theta), -sin(in.theta); sin(in.theta), cos(in.theta)]*[in.x in.y]';
if ~exist('YTcor','var')||isempty(YTcor),
    YTcor.org_globalx = 0;
    YTcor.org_globaly = 0;
end
try
    t1 = in.speed;
catch
    in.speed = 0;
    in.t=0;
end
if isempty(theta) || theta ~= in.theta
    theta = in.theta;
    c = cos(in.theta);
    s = sin(in.theta);
end

X = (c*in.x - s*in.y + in.speed*in.t) + YTcor.org_globalx;
Y = (s*in.x + c*in.y + 0*in.t) + YTcor.org_globaly;

O.x=X;
O.y=Y;

return