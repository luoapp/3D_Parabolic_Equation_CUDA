function [SSP, SENSOR_DEPTH, WATERDEPTH, TEMPR, SALT] = sub_SSPatNRL300(DATA,TIME,isplotcontour)
% Extract SSP profiles at the NRL300
%    [SSP, SENSOR_DEPTH, WATERDEPTH, TEMPR, SALT] = sub_SSPatNRL300(DATA_STRUCTURE,TIME,[isplotcontour])
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

SSP(:,find(IDT>0&IDT<=134641)) = DATA.SNDSPD(:,IDT(find(IDT>0&IDT<=134641)));
SENSOR_DEPTH(:,find(IDT>0&IDT<=134641)) = DATA.SENSOR_DEPTH(:,IDT(find(IDT>0&IDT<=134641)));
WATERDEPTH(:,find(IDT>0&IDT<=134641)) = DATA.WATERDEPTH(:,IDT(find(IDT>0&IDT<=134641)));
TEMPR(:,find(IDT>0&IDT<=134641)) = DATA.T(:,IDT(find(IDT>0&IDT<=134641)));
SALT(:,find(IDT>0&IDT<=134641)) = DATA.SALT(:,IDT(find(IDT>0&IDT<=134641)));

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
    [cs,h]=contourf(repmat(TIME,size(SSP,1),1),SENSOR_DEPTH,SSP,CAXIS);
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
    title(sprintf('Water Column at the NRL300 Source %s',datestr(TIME(1),'at HH:MM:SS on mmm/dd')),'fontsize',18)
    
    subplot(312);
    CAXIS = linspace(6,32,11);
    [cs,h]=contourf(repmat(TIME,size(TEMPR,1),1),SENSOR_DEPTH,TEMPR,CAXIS);    
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
    [cs,h]=contourf(repmat(TIME,size(SALT,1),1),SENSOR_DEPTH,SALT,CAXIS);  
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

    