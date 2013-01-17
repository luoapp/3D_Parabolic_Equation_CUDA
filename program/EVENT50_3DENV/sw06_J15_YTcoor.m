function out = sw06_J15_YTcoor(time_of_interest)
%clear;
%close all

%time_of_interest = [ datenum('17-Aug-2006 22:11:00') datenum('17-Aug-2006 22:27:00')];

sharp= sw06_mooring_position('sharp');
sharp.length = 44.5;
sharp.tow_rope = 40.87;

trans = sw06_event50_transmission('both');
time_limit = [trans.time(1,1)-1/24,trans.time(end,2)+1/24];
ix1 = max(find(sharp.GMT<=time_limit(1)));
ix2 = max(find(sharp.GMT<=time_limit(2)));
sharp.GMT=sharp.GMT(ix1:ix2);
sharp.LATITUDE = sharp.LATITUDE(ix1:ix2);
sharp.LONGITUDE = sharp.LONGITUDE(ix1:ix2);
[sharp.x sharp.y]=sw06_sph2grid(sharp.LONGITUDE,sharp.LATITUDE);
sharp.x = -sharp.x;
sharp.y = -sharp.y;

average_window = ones(3 *60 /10,1); %samples, 10sec interval
average_window = average_window/length(average_window);
sharp.dx = filter(average_window, 1, diff(sharp.x)./diff(sharp.GMT)/3600/24);
sharp.dy = filter(average_window, 1, diff(sharp.y)./diff(sharp.GMT)/3600/24);

E35=load('e35');


for ix_t = 1:length(time_of_interest)
    
    xe(ix_t) = interp1(sharp.GMT,sharp.x,time_of_interest(ix_t));  %earth coord
    ye(ix_t) = interp1(sharp.GMT,sharp.y,time_of_interest(ix_t));
    dx = interp1(sharp.GMT(2:end),sharp.dx,time_of_interest(ix_t));
    dy = interp1(sharp.GMT(2:end),sharp.dy,time_of_interest(ix_t));
    xe(ix_t) = xe(ix_t) - (sharp.tow_rope + sharp.length/2) * dx / (dx^2+dy^2)^0.5;
    ye(ix_t) = ye(ix_t) - (sharp.tow_rope + sharp.length/2) * dy / (dx^2+dy^2)^0.5;
    z(ix_t) = interp1(E35.GMT, E35.depth, time_of_interest(ix_t));
    
    
end

PEcoor.theta = -62.8510/180*pi;
x = xe .* cos(PEcoor.theta) - ye.*sin(PEcoor.theta);
y = xe .* sin(PEcoor.theta) + ye.*cos(PEcoor.theta);

out.PEcoor.x = x;
out.PEcoor.y = y;
out.PEcoor.z = z;


out.Earthcor.x = xe;
out.Earthcor.y = ye;
out.Earthcor.z = z;

    

