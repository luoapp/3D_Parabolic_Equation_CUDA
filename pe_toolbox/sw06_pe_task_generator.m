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
task.time = trans.time(ix_trans,1)+offset:interval:trans.time(ix_trans,2);
task.source = ones(size(task.time))*source.id;
task.priority = ones(size(task.time))*priority;
task.freq = ones(size(task.time))*source.freq;
task_filename = 'sw06_pe_task.mat';
if exist(task_filename,'file')
    D=load(task_filename);
    task.time = [D.task.time task.time];
    task.source = [D.task.source task.source];
    task.priority = [D.task.priority task.priority];
    task.freq = [D.task.freq task.freq];
end

a=[];
n = 1;
ixt = 1:length(task.time); ixt2=[-1];
while 1
    task_found = 0;
    for ix = n+1:length(task.time)
        if sum(ixt2==n)>0
            task_found = 1;
            break;
        end
        if  sum(ixt2 == ix) >0
            continue;
        end
        if task.time(n) == task.time(ix) && task.source(n) == task.source(ix)
            ixt2 =[ixt2, ix];
            if task.priority(n)>task.priority(ix)
                a = [a n];
            else
                a = [a ix];
            end
            task_found =1;
            break;
        end
    end
    if task_found == 0  && sum(ixt2==n) ==0

        a = [a n];
    else
        task_found = 0;
    end
    if n >= length(task.time)
        break;
    end
    n = n+1;
    
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
n = 1;
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
        task.priority(n) = task1.priority(ix_t);
        task.time(n) = task1.time(ix_t);
        task.source(n) = task1.source(ix_t);
        task.freq(n) = task1.freq(ix_t);
        n = n+1;
    end
end

save(task_filename,'task');
sw06_pe_task_viewer;