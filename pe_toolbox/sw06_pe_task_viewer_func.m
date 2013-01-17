function sw06_pe_task_viewer_func( task )
if ~exist('task','var')
    task_filename = '../pe_toolbox/sw06_pe_task.mat';
    if exist(task_filename, 'file')
        load(task_filename);
    else
        warning('task file not found');
    end
end
if isempty( task(1).priority )
    warning('no scheduled task');
end

[ task1.priority, ix ] = sort([task.priority], 'descend');
task1.time = task.time(ix);
task1.source = task.source(ix);
task1.freq = task.freq(ix);

matfiledir = '../mat/pe_result/';
matfiles = dir( [matfiledir, '*.mat']);

for ix=1:length(task1.priority)
    tp = task1.priority(ix);
    tt = task1.time(ix);
    ts = task1.source(ix);
    tf = task1.freq(ix);
    
    task_found = 0;
    for ix_f=1:length(matfiles)
        info = sw06_pe_matfileinfo(matfiles(ix_f).name);
        if info.freq == tf && abs(info.time - tt) < 1/60/60/24
            task_found = 1;
            break;
        end
    end
    
    O1 = sw06_source_id(ts);
    if task_found == 1
        fprintf('Obsolete task %s %s priority=%d \n',O1.pename,datestr(tt),tp)
    else
        fprintf('Waiting task %s %s priority=%d \n',O1.pename,datestr(tt),tp)
    end
    
end

fprintf('%d tasks waiting\n',length(task.time));