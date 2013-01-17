function info = sw06_pe_matfileinfo(filename)
% if length(filename)~=52 && length(filename)~=57 && length(filename)~=22 ...
%         && length(filename) ~= 25
%     error('Unknown file!');
% end
if length(filename) == 22 && strcmp(filename(16:18),'HLA')  %SW06_PE_j15_M1_HLA.mat
    info.sourcename = upper(filename(9:11));
    info.trans = filename(13:14);
elseif length(filename) == 25 && strcmp(filename(19:21),'HLA')%SW06_PE_nrl300_F3_HLA.mat
     info.sourcename = upper(filename(9:14));
    info.trans = filename(16:17);
   
elseif length(filename) ==52
    info.freq = str2num(filename(31:33));
    info.time = datenum(filename(35:48),'ddmmmyy_HHMMSS');
    info.zindex = [];
    
elseif length(filename) == 57
    info.freq = str2num(filename(31:33));
    info.time = datenum(filename(35:48),'ddmmmyy_HHMMSS');
    info.zindex = [];
    info.xindex = str2num(filename(50:53));
else
    error('Unknown file!');
end

if info.freq == 250
    info.source = 'J15';
else
    info.source = 'NRL300';
end

