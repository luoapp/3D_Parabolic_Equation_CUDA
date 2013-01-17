clear
%close all
sourcename = upper('j15');

trans = sw06_transmission(sourcename);



if strcmp(sourcename,'J15')
    f0=250;
    transid = 'M';
elseif strcmp(sourcename,'NRL300')
    f0=300;
    transid = 'F';
end

shark_vla = sw06_rcvr_config('shark_vla');
z1=-[1:1:max(shark_vla.depth)];
c0=1500;
freq = f0;
y_offset = 0;
for ix_t = 4%:4
    datadir = sprintf('../m%d/mat0/pe_result/',ix_t);
    figdir = sprintf('../m%d/figures/vla/',ix_t);
    cudafiledir = sprintf('../m%d/mat0/cuda/',ix_t);

    files = dir([datadir,'SW50EVT50*.mat']);
    x_axis = trans.time(ix_t):0.5/60/24:trans.time(ix_t)+15/60/24;

    n = 0;
    
    for ix_f = 1:length(files)
        matinfo = sw06_pe_matfileinfo([ files(ix_f).name(1:end-11),'.mat']);
        
        if matinfo.freq ~=f0
            continue;
        end
        
        cuda_filename = [cudafiledir,'freq',num2str(matinfo.freq),'_', datestr(matinfo.time,'ddmmmyy_HHMMSS'),...
            files(ix_f).name(49:55),'_cuda.mat'];
        load(cuda_filename);
        lambda=c0/freq ;
        dx=steplength;
        dy=wid/ny;
        dz=wid/aspect/nz;
        y=(-0.5*ny*dy):dy:(0.5*ny*dy)-dy;
        z=(-0.5*nz*dz):dz:(0.5*nz*dz)-dz;
        [Y,Z]=meshgrid(y,z);
        Ly=max(y)-min(y);
        Lz=max(z)-min(z);
        x=[0 (ndxout:ndxout:numstep)*steplength];
        
        n = n+1;
        load([datadir,files(ix_f).name]);
        pe.geotime(n)=matinfo.time;
        ix_z = find((z<=max(shark_vla.depth)).*(z>=0));
        %imagesc(20*log10(abs(psifinal(ix_z,:)))); 
        %caxis([-70 -50])
        
        %drawnow;
        t1 = 20*log10(abs(psifinal(ix_z,y_offset+length(y)/2)));
        %t1 = 20*log10(abs(psifinal(ix_z,:)));
        t2 = sum(abs(psifinal(ix_z,length(y)/2))*2);
        t3=abs(psifinal(ix_z,:));
        %pe.intens(n,:) = interp1(z, t1, z1);
        pe.intens(n,:) = t1;
        pe.intens_int(n) = t2;
        pe.intens1(n,:,:) = t3;
    end
 
    
     figure;
    set(gcf,'position',[      100         -171         636         795]);
    ax_vla = axes;
    ax_intens = axes;
    set(ax_intens,'position',[  0.1300    0.3773    0.74    0.22]);
    set(ax_vla,'position',[0.13    0.6741    0.74    0.22]);
    set(ax_vla,'fontsize',14,'fontweight','bold');
    set(ax_intens,'fontsize',14,'fontweight','bold');
    
    for y_offset = [-200 :200]
    axes(ax_vla);
    
    %imagesc(pe.geotime,z(ix_z),pe.intens.')
    t4 = squeeze(pe.intens1(:,:,y_offset+length(y)/2));
    imagesc(pe.geotime,z(ix_z),20*log10(t4)');
    %imagesc(pe.intens1.')
    
    caxis([-70 -50])
    title(num2str(y_offset))
    datetick
    axis tight
    xlabel('getotime')
    ylabel('depth')
    set(gca,'ydir','reverse');
    axes(ax_intens);
    plot(pe.geotime,10*log10(sum(t4.')));
    %plot(pe.geotime,10*log10(pe.intens_int));
%     hold on;
%     plot(sum(pe.intens1.'),'r')
    datetick
    axis tight
    pause
    end
    %     if n > 0
    %         [gt ixs] = sort(pe.geotime);
    %         intens = pe.intens(ixs,:);
    %         %save(sprintf('%sSW06_PE_%s_%s%d_VLA',figdir,sourcename,transid,ix_t),'intens','pe');
    %         clear pe intens
    %     end
end