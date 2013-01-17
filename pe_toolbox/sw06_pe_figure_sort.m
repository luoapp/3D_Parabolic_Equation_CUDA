clear;
figdir = '..\Figures\';
files = dir([figdir,'others\*.png']);



for ix=1:length(files)
    info = sw06_pe_figureinfo(files(ix).name);
    if info.freq == 250
        sid = 'M';
        sname = 'j15';
    elseif info.freq == 300
        sid = 'F';
        sname = 'nrl300';
    else
        error('unknown source');
    end
    
    trans = sw06_event50_transmission(sname);
    tid = find( (info.time>= trans.time(:,1)-10/3600/24)...
        .* (info.time<= trans.time(:,2)+10/3600/24));
    if length(tid)==1
        subdir = [figdir,'topview\',sprintf('%s%d', sid, tid),'\'];
        f1 = dir([subdir,files(ix).name]);
        
        tobereplaced = 1;
        if ~isempty(f1)
            t1 = datenum(files(ix).date);
            t2 = datenum(f1.date);
            if t1<= t2
                tobereplaced = 0;
                eval(['!del ', figdir,'others\',files(ix).name]);
            end
        end
        if tobereplaced
            eval(['!move ', figdir,'others\',files(ix).name,...
                ' ',subdir]);
        end
        
    else
        warning('unknown tid');
        files(ix)
    end
    
end