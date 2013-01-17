clear;
task_filename = 'sw06_pe_task.mat';

while 1
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
    k = task.time + task.source*100;
    [k ixk] = sort(k);
    dk = diff(k);
    t = find(abs(dk)<1/60/60/24);
    
    a = [];
    for ix=1:length(k)
        if sum(t==ix) == 0
            a =[a ixk(ix)];
        end
    end
    task.priority = task.priority(a);
    task.time = task.time(a);
    task.source = task.source(a);
    task.freq = task.freq(a);
    
    clear task1;
    [ task1.priority, ix ] = sort(task.priority, 'descend');
    task1.time = task.time(ix);
    task1.source = task.source(ix);
    task1.freq = task.freq(ix);
    
    
    matfiledir = '../mat/vla/';
    matfiles = dir( [matfiledir, '*.mat']);
    
    task.time = [];
    task.priority = [];
    task.freq = [];
    task.source = [];
    n = 0;
    for ix_t = 1:length(task1.time)
        task_found = 0;
        for ix=1:length(matfiles)
            info = sw06_pe_matfileinfo(matfiles(ix).name);
            if info.freq == task1.freq(ix_t) && abs(info.time - task1.time(ix_t)) < 1/60/60/24
                task_found = 1;
                break;
            end
        end
        
        if task_found == 0
            if n == 0
                O.priority = task1.priority(ix_t);
                O.time = task1.time(ix_t);
                O.source = task1.source(ix_t);
                O.freq = task1.freq(ix_t);
            else
                task.priority(n) = task1.priority(ix_t);
                task.time(n) = task1.time(ix_t);
                task.source(n) = task1.source(ix_t);
                task.freq(n) = task1.freq(ix_t);
                
            end
            n = n+1;
        end
    end
    
    save(task_filename,'task');
    if isempty(task.time)
        warning('no scheduled task');
        continue;
    else
        O1 = sw06_source_id(O.source);
        O.ISOURCE = O1.pename;
        O.Data_window_cental_time = O.time;
        fprintf('Task %s %s dispatched \n',O.ISOURCE, datestr(O.Data_window_cental_time))
        break;
    end
end