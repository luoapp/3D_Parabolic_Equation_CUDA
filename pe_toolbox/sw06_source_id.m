function O = sw06_source_id( s )
if ischar(s)
    if strcmp(lower(s),'j15')
        O.name = 'J15';
        O.pename = 'UDelJ15';
        O.id = 1;
        O.freq = 250;
    elseif strcmp(lower(s),'nrl300');
        O.name = 'NRL300';
        O.pename = O.name;
        O.id = 2;
        O.freq = 300;
    else
        error('Unknown source!')
    end
else
    if s == 1
        O.name = 'J15';
        O.pename = 'UDelJ15';
        O.id = 1;
        O.freq = 250;
    elseif s == 2
        O.name = 'NRL300';
        O.pename = O.name;
        O.id = 2;
        O.freq = 300;
    else
        error('Unknown source!')
    end
end