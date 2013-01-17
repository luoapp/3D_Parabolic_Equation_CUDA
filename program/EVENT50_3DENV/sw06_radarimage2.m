function O=sw06_radarimage2(time_of_interest, RV)
%find the radar image at time_of_interest
%persistent sharp oceanus

%time_of_interest = datenum('17-Aug-2006 18:50:04');
%RV = 'sharp';
%sharp=[];oceanus=[];
sharp.dir='J:\sw06_udel\data\Ship-Radar\08-17-06\Event50\';
sharp.file = dir([sharp.dir,'160806r*.jpg']);

for ix=1:length(sharp.file)
    sharp.time(ix) = sw06_radar_time(sharp.file(ix).name);
end


oceanus.dir='\sw06_Oceanous\radar_for_ev50\';
oceanus.file=dir([oceanus.dir,'2006*.png']);
for ix=1:length(oceanus.file)
    oceanus.time(ix) = sw06_radar_time(oceanus.file(ix).name);
end


if strcmp(upper(RV), 'SHARP')
    rv = sharp;
elseif strcmp(upper(RV), 'OCEANUS') || strcmp(upper(RV), 'OCEANOUS')
    rv = oceanus;
else
    error('Unknonw RV');
end

ix = max(find(rv.time<=time_of_interest));
[B M]=sw06_radarimage([rv.dir,rv.file(ix).name]);
O.image = B;
O.mask = M;
O.radius = 3* 1.85200e3;
O.x_grid = [-floor(size(O.image,2)/2):size(O.image,2)-1-floor(size(O.image,2)/2)]*2/size(O.image,2)*O.radius;
O.y_grid = [-floor(size(O.image,1)/2):size(O.image,1)-1-floor(size(O.image,1)/2)]*2/size(O.image,1)*O.radius;

