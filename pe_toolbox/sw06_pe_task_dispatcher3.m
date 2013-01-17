function O = sw06_pe_task_dispatcher3()
clear
O.Data_window_cental_time = -1;
task_filename = '../pe_toolbox/sw06_pe_task.mat';

while(1)
    if exist(task_filename, 'file')
        load(task_filename);
    else
        warning('task file not found');
        pause(60+60*rand());
        continue;
    end
    if isempty( task.priority )
        warning('no scheduled task');
        pause(60+60*rand());
        continue;
    end
    
    
    tp = task.priority(1);
    tt = task.time(1);
    ts = task.source(1);
    tf = task.freq(1);
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
    
    O1 = sw06_source_id(ts);
    
    O.ISOURCE = O1.pename;
    O.Data_window_cental_time = tt;
    fprintf('Task %s %s p=%d dispatched \n',O.ISOURCE, ...
        datestr(O.Data_window_cental_time),tp);
    break;
end

