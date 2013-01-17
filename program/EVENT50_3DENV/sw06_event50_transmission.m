function O = sw06_event50_transmission(INST)
tudel(:,1) =  [datenum([2006 8 17 21 11 0]):1/24/2:datenum([2006 8 17 23 11 0])];
tudel(:,2) =  [datenum([2006 8 17 21 27 0]):1/24/2:datenum([2006 8 17 23 27 0])];
tnrl(:,1) =  [datenum([2006 8 17 20 30 0]):1/24/2:datenum([2006 8 17 23 30 0])];
tnrl(:,2) =  [datenum([2006 8 17 20 37 0]):1/24/2:datenum([2006 8 17 23 37 0])];
t=[tudel;tnrl];
t(:,1)=sort(t(:,1));
t(:,2)=sort(t(:,2));
if ~exist('INST')
    O.time = t;
    return;
end

if strcmp(upper(INST),'UDEL') == 1 || strcmp(upper(INST),'SHARP') == 1
    O.time = tudel;
    return
elseif (strcmp(upper(INST),'NRL300') == 1)||(strcmp(upper(INST),'WHOI') == 1)
    O.time = tnrl;
    return;
elseif strcmp(upper(INST),'BOTH') == 1 %both udel and nrl300
    O.time = t;
    return;
elseif strcmp(upper(INST),'EV50') == 1  %start and end of ev50
    t3(1,1)=datenum('17-Aug-2006 18:00:00');
    t3(1,2)=datenum('18-Aug-2006 06:00:00');
    O.time = t3;
    return;
else
    error('Error: Unknown name');
end