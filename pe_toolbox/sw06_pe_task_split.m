function sw06_pe_task_split()
task_filename = '../pe_toolbox/sw06_pe_task.mat';
load(task_filename);
l1 = length(task.time);
local_ix = [1 2 3:2:l1];
remote_ix = [4:2:l1];
task_local.time = task.time(local_ix);
task_local.priority = task.priority(local_ix);
task_local.source = task.source(local_ix);
task_local.freq = task.freq(local_ix);
task_remote.time = task.time(remote_ix);
task_remote.priority = task.priority(remote_ix);
task_remote.source = task.source(remote_ix);
task_remote.freq = task.freq(remote_ix);
fprintf('Local tasks:\n')
sw06_pe_task_viewer_func(task_local);
fprintf('\n\n----------\nRemote tasks:\n')
sw06_pe_task_viewer_func(task_remote);
task = task_local;
save('../pe_toolbox/sw06_pe_task.local.mat','task');
task = task_remote;
save('../pe_toolbox/sw06_pe_task.remote.mat','task');
