function info = sw06_pe_envinfo(filename)
if length(filename)==39
    info.sourcename = filename(15:20);
    info.time = datenum(filename(22:35),'ddmmmyy_HHMMSS');
    info.freq = 300;
elseif length(filename)==40
    info.sourcename = filename(16:21);
    info.time = datenum(filename(23:36),'ddmmmyy_HHMMSS');
    info.freq = 250;
else
    error('Unknown file!');
end

