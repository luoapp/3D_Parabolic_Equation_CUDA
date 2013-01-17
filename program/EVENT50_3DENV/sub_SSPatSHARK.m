function [SSP, SENSOR_DEPTH, WATERDEPTH, TEMPR, SALT] = sub_SSPatSHARK(DATA,TIME,isplotcontour)
% Extract SSP profiles at the SHARK VLA
%    [SSP, SENSOR_DEPTH, WATERDEPTH, TEMPR, SALT] = sub_SSPatSHARK(DATA_STRUCTURE,TIME,[isplotcontour])
% Input:
%       DATA_STRUCTURE - preloaded data structure, which contains all of sound
%                 speed profiles during the SW06 experiment at the SHARK VLA 
%                 (The data structure is saved in SSPatSHARK.mat)
%       TIME - this could be a scale number or a ROW vector (in Matlab Time
%              format)
% Output:
%       SSP - Sound speed profilesa on the columns
%       SENSOR_DEPTH - Sensor depths on the columns
%       WATERDEPTH
%
% YT Lin @ WHOI

if ~exist('isplotcontour','var'),
    isplotcontour = 0;
end

dt = 30/60/60/24;

SSP = nan(size(DATA.SNDSPD,1),length(TIME));

IDT = round((TIME - DATA.JDVEC(1))/dt) + 1;

SSP(:,find(IDT>0&IDT<=108903)) = DATA.SNDSPD(:,IDT(find(IDT>0&IDT<=108903)));
SENSOR_DEPTH(:,find(IDT>0&IDT<=108903)) = DATA.SENSOR_DEPTH(:,IDT(find(IDT>0&IDT<=108903)));
WATERDEPTH(:,find(IDT>0&IDT<=108903)) = DATA.WATERDEPTH(:,IDT(find(IDT>0&IDT<=108903)));
TEMPR(:,find(IDT>0&IDT<=108903)) = DATA.T(:,IDT(find(IDT>0&IDT<=108903)));
SALT(:,find(IDT>0&IDT<=108903)) = DATA.SALT(:,IDT(find(IDT>0&IDT<=108903)));

% Temperature at the 6th row stops at 104102.
%
% Salinity at the 1st row stopes at 102062.
%                 2                 102062
%                 3                 102062
%                 4                 102062
%                 5                 102062
%                 6                 102062
%                 7                 103138
%                 8                 103138
%                 9                 101435
%                10                 100330
%                11                 100248
%                12                 102127
%                13                 100071
%                14                 100071
%                15                  98366
ITRUNC_SALT=[ 102062 108903
              102062 108903
              102062 108903
              102062 108903
              102062 108903
              102062 104102
              103138 108903
              103138 108903
              101435 108903
              100330 108903
              100248 108903
              102127 108903
              100071 108903
              100071 108903
               98366 108903];

ployfit_power = 2;

for idz = 1:size(DATA.SNDSPD,1);
    itmp = find(IDT>=ITRUNC_SALT(idz,1)&IDT<=ITRUNC_SALT(idz,2));
    if ~isempty(itmp),
        tmp = [ (ITRUNC_SALT(idz,1)-1-2*60*24*7+1):(ITRUNC_SALT(idz,1)-1)];  % Take five-day salinity data before it ends
        TEMPR_tmp = DATA.T(idz,tmp);
        SALT_tmp = DATA.SALT(idz,tmp);
        [TEMPR_tmp,isort] = sort(TEMPR_tmp); SALT_tmp = SALT_tmp(isort);
        [TEMPR_norep,SALT_norep] = remove_rep(TEMPR_tmp,SALT_tmp);
        pcoef = polyfit(TEMPR_norep,SALT_norep,ployfit_power);
        SALT(idz,itmp) = polyval(pcoef,DATA.T(idz,IDT(itmp)));
        SSP(idz,itmp) = sndspd(polyval(pcoef,DATA.T(idz,IDT(itmp))),DATA.T(idz,IDT(itmp)),SENSOR_DEPTH(idz,itmp)/.995,'chen');
    end
end

for idz = 1:size(DATA.SNDSPD,1);
    itmp = find(isnan(SSP(idz,:)));
    if ~isempty(itmp),
        SSP(idz,itmp) = mean(SSP([max(1,idz-1) min(size(DATA.SNDSPD),idz+1)],itmp),1);
    end
end

if isplotcontour,
    figure;
    set(gcf,'Position',[232 34 560 663],'PaperPosition',[0.25 0.25 8 10.5])
    
    subplot(311);
    CAXIS = linspace(1480,1540,11);
    [cs,h]=contourf(repmat(TIME,15,1),SENSOR_DEPTH,SSP,CAXIS);
    % clabel(cs,h);
    hold on; plot(TIME,SENSOR_DEPTH.','w:')
    set(gca,'tickdir','out','fontsize',14)
    colormap(jet(length(CAXIS)-1))
    caxis([min(CAXIS) max(CAXIS)])
    ch = colorbar; 
    set(get(ch,'ylabel'),'string','Sound Speed (m/s)','fontsize',16)
    set(ch,'ytick',CAXIS(1:2:end),'yticklabel',CAXIS(1:2:end),'fontsize',18)
    axis ij
    ylabel('Depth (m)','fontsize',18)
    tmp = xlim;
    ylim([0 80])
    datetick('x','keeplimits','keepticks')
    title(sprintf('Water Column at the SHARK VLA %s',datestr(TIME(1),'at HH:MM:SS on mmm/dd')),'fontsize',18)
    
    subplot(312);
    CAXIS = linspace(6,32,11);
    [cs,h]=contourf(repmat(TIME,15,1),SENSOR_DEPTH,TEMPR,CAXIS);    
    % clabel(cs,h);
    hold on; plot(TIME,SENSOR_DEPTH.','w:')
    set(gca,'tickdir','out','fontsize',14)
    colormap(jet(length(CAXIS)-1))
    caxis([min(CAXIS) max(CAXIS)])
    ch = colorbar; 
    set(get(ch,'ylabel'),'string','Temperature (\circC)','fontsize',16)
    set(ch,'ytick',CAXIS(1:2:end),'yticklabel',CAXIS(1:2:end),'fontsize',14)
    axis ij
    xlim(tmp);
    ylim([0 80])
    datetick('x','keeplimits','keepticks')
    ylabel('Depth (m)','fontsize',18)


    subplot(313);
    CAXIS = linspace(28,35,11);
    [cs,h]=contourf(repmat(TIME,15,1),SENSOR_DEPTH,SALT,CAXIS);  
    % clabel(cs,h);
    hold on; plot(TIME,SENSOR_DEPTH.','w:')
    set(gca,'tickdir','out','fontsize',14)
    colormap(jet(length(CAXIS)-1))
    caxis([min(CAXIS) max(CAXIS)])
    ch = colorbar; 
    set(get(ch,'ylabel'),'string','Salinity (ppt)','fontsize',16)
    set(ch,'ytick',CAXIS(1:2:end),'yticklabel',CAXIS(1:2:end),'fontsize',14)
    axis ij
    ylabel('Depth (m)','fontsize',18)
    xlabel('Time','fontsize',18)
    xlim(tmp);
    ylim([0 80])
    datetick('x','keeplimits','keepticks')
    
end

return

% =========================================================================
function [X_norep,Y_norep] = remove_rep(X,Y)

X = X(:).';
Y = Y(:).';

X_norep = [X(1) X(find(diff(X)~=0) + 1)];
idx0 = [1 (find(diff(X)~=0) + 1)];
idx1 = [idx0(2:end)-1 length(X)];
Y_norep = Y(idx0);

irep = find((idx1-idx0)+1 ~=1);

for itmp = 1:length(irep);
    Y_norep(irep(itmp)) = mean(Y(idx0(irep(itmp)):idx1(irep(itmp))));
end

return

    