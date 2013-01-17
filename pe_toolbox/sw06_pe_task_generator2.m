function sw06_pe_task_generator(Tx, interval,offset, priority)
addpath ('../sw06_toolbox');

%clear all;

% Tx = 'm3';
% priority = 1;

interval = interval/60/60/24;    %sec
offset = offset /60/60/24;

if strcmp(Tx(1),'m')
    source = sw06_source_id('j15');
elseif strcmp(Tx(1),'f')
    source = sw06_source_id('nrl300');
else
    error('unknown source');
end
ix_trans = str2num(Tx(2));

trans = sw06_event50_transmission(source.name);
t1= trans.time(ix_trans,1)+offset:interval:trans.time(ix_trans,2);
for ix = 1:length(t1)
    task(ix).time = t1(ix);
    task(ix).source = source.id;
    task(ix).priority = priority;
    task(ix).freq = source.freq;
end
task_filename = 'sw06_pe_task.mat';
if exist(task_filename,'file')
    D=load(task_filename);
    task = [D.task task];
end

save(task_filename, 'task');

