function O = sw06_mooring_position(instrument)
persistent longlat
lat = [];
long = [];
depth = [];
if instrument == -1
    instrument = 'J15';
end
if strcmp(upper(instrument), 'SHARP')       %do not distinguish between rv sharp and j15
    instrument = 'J15';
end
if strcmp(upper(instrument),'J15')
    load('positions_event50.mat');
    lat = LATITUDE;
    long = -LONGITUDE;
    O.GMT = GMT;
end
if strcmp(upper(instrument),'OCEANUS')
    load('oceanus.mat');
    O.INSTRUMENT = upper(instrument);
    O.LATITUDE = LATITUDE;
    O.LONGITUDE = -LONGITUDE;
    O.DEPTH = [];
    O.GMT = GMT;
    return;
end

if isempty(longlat)
    %%% Moorings locations
    load mooring_longlat;
end


if ~ischar(instrument)
    if instrument>=longlat(1,1) && instrument<=longlat(end,1)
        O.LATITUDE = longlat(instrument,2)+longlat(instrument,3)/60;;
        O.LONGITUDE = -longlat(instrument,4)-longlat(instrument,5)/60;;
        O.INSTRUMENT = ['SW',upper(num2str(instrument))];
        O.DEPTH = 0;
        return;
    else
        error('ERROR: Unknown instrument');
    end
end
if iscell(instrument)
    instrument =instrument{1};
end
eq1 = upper(instrument);
switch eq1
    case 'J15'
        depth = [depth 40];
    case 'NRL300'
        long=[long -72-56.575/60]; % NRL 300Hz
        lat =[lat 39+10.9574/60];
        depth = [depth 72];
    case {'SHARK_VLA','SHARK'}
        long=[long -73-2.9887/60]; % SHARK
        lat = [ lat 39+1.2627/60];
        recv = sw06_rcvr_config(eq1);
        depth = recv.depth;
    case 'SHARK_HLA_END'
        %%% SHARK HLA Tail location
        long=[long -73-2.9782/60];
        lat =[lat 39+1.5831/60];
    case 'STR'
        %%% Structure Mooring locations
        l1 = -longlat(1:28,4)-longlat(1:28,5)/60;
        long=[long l1'];
        l2 = longlat(1:28,2)+longlat(1:28,3)/60;
        lat =[lat l2'];
    case 'ENV'
        %%% Environt Mooring locations
        emlong=-longlat(29:34,4)-longlat(29:34,5)/60;
        long = [long emlong'];
        emlat =longlat(29:34,2)+longlat(29:34,3)/60;
        lat = [lat emlat'];
    case 'SHRU'
        %%% SHRU #1-5
        shlong=-longlat(49:53,4)-longlat(49:53,5)/60;
        shlat =longlat(49:53,2)+longlat(49:53,3)/60;
        long = [long shlong'];
        lat = [lat shlat'];
    otherwise
        error('ERROR: Unknown instrument');
end


O.INSTRUMENT = upper(instrument);
O.LATITUDE = lat;
O.LONGITUDE = long;
O.DEPTH = depth;
return;