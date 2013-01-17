function info = sw06_pe_figureinfo(filename)
if length(filename)==59
    offset = 2;
elseif length(filename)==57
    offset = 0;
else
    error('Unknown file!');
end

info.freq = str2num(filename(offset+[36:38]));
info.time = datenum(filename(offset+[40:53]),'ddmmmyy_HHMMSS');

