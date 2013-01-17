function sw06_pe_task_merger(task1,task2)
unfinished
return;
if ~exist('task2','var')
    if ~exist('task1','var')
        remote_task_filename = '../pe_toolbox/sw06_pe_task.remote.mat';
        load(remote_task_filename);
        remote_task = task;
    else
        remote_task = task1;
    end
    local_task_filename = '../pe_toolbox/sw06_pe_task.mat';
    load(local_task_filename);
    local_task=task;
end
tl = length(remote_task.time);
