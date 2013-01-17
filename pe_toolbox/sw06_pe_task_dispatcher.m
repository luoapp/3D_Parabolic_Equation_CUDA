%function O = sw06_pe_task_founder()
clear
O.Data_window_cental_time = -1;
task_filename = 'sw06_pe_task.mat';

while(1)
    if exist(task_filename, 'file')
        load(task_filename);
    else
        warning('task file not found');
        pause(60);
        continue;
    end
    if isempty( task.priority )
        warning('no scheduled task');
        pause(60);
        continue;
    end
    
    [ task1.priority, ix ] = sort(task.priority, 'descend');
    task1.time = task.time(ix);
    task1.source = task.source(ix);
    task1.freq = task.freq(ix);
    
    tp = task1.priority(1);
    tt = task1.time(1);
    ts = task1.source(1);
    tf = task1.freq(1);
    task = task1;
    if length(task.priority) >= 2
        task.priority = task.priority(2:end);
        task.time = task.time(2:end);
        task.source = task.source(2:end);
        task.freq = task.freq(2:end);
    else
        task.priority = [];
        task.time = [];
        task.source = [];
        task.freq = [];
    end
    save(task_filename, 'task');
    matfiledir = '../mat/vla/';
    matfiles = dir( [matfiledir, '*.mat']);
    
    task_found = 0;
    for ix=1:length(matfiles)
        info = sw06_pe_matfileinfo(matfiles(ix).name);
        if info.freq == tf && abs(info.time - tt) < 1/60/60/24
            task_found = 1;
            break;
        end
    end
    O1 = sw06_source_id(ts);
    
    if task_found == 0
        O.ISOURCE = O1.pename;
        O.Data_window_cental_time = tt;
        fprintf('Task %s %s dispatched \n',O.ISOURCE, datestr(O.Data_window_cental_time))
        break;
    elseif task_found == 1
        warning(['task:[',O1.pename,' ',datestr(tt),'] already excuted, moving on to next']);
    else
        error('unknown error in task dispatcher');
    end
    
end

