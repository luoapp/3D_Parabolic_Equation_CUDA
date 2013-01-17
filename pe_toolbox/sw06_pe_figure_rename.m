clear

figuredir = sw06_get_filepath( 'sw06_pe_temp_intens_fig');
files = dir([figuredir,'SW50*.png']);

for ix = 1:length(files)
    eval(['!mv ',files(ix).name,' sw06',files(ix).name(10:end)]);
end