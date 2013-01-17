clear all;
close all;
addpath ('../pe_toolbox');
addpath ('../../luo_toolbox/sw06_toolbox/');
addpath ('./EVENT50_3DENV/')

 matdir = '../mat/';
envfilepath = [matdir,'env/'];
peresultpath = [matdir, 'pe_result/'];
ssp3dfieldpath = [matdir,'3d_field/'];
trans=sw06_transmission('j15');

time_window = trans.time(1):0.5/24/60:trans.time(1)+15/60/24;

for ix_tw = 1:length(time_window)
    %Data_window_cental_time = O.Data_window_cental_time;
    
    ISOURCE = 'UDelJ15';
    
    % which source and transmission period?
    % ISOURCE = 'NRL300';
    % Data_window_cental_time = [datenum('17-Aug-2006 21:30:00'):.5/60/24:datenum('17-Aug-2006 21:38:00')];
    %ISOURCE = 'UDelJ15';
    %Data_window_cental_time = [datenum('17-Aug-2006 22:18:00'):0.5/60/24:datenum('17-Aug-2006 22:18:00')];
    
    isplot = 0;     % 0 means do not plot any figures that 3DPE generates
    
    
    
    
    % 1) make up an environemtal model
    % -----------------------------------
    
    
    PEcoor.ylim = [-2500 2500];
    PEcoor.zlim = [0 90];
    PEcoor.dx = 100;
    PEcoor.dy = 50;
    PEcoor.dz = 5;
    %profiling
    %PEcoor.dx = 200;
    %PEcoor.dy = 200;
    %PEcoor.dz = 10;
    
    PEcoor.plot = 0;
    PEcoor.clim = [10 25];
    PEcoor.print = 0;
    PEcoor.plot_radar = 0;
    PEcoor.time =  time_window(ix_tw);
    
    switch ISOURCE,
        case 'NRL300'
            freqs = 300;   % source frequency
        case 'UDelJ15'
            freqs = 250;  % source frequency?
    end
    icase = 'event50';
    outfile = sprintf('SW50EVT50_%s_3DWAPE_freq_%d_%s.mat',...
        icase,freqs,datestr(PEcoor.time,'ddmmmyy_HHMMSS'));
    %save([matdir,'pe_result\' outfile], 'PEcoor');
    
    [BATHY, TEMPR, SRC, RCV] = sw06_ev50_3DSPDField(PEcoor,ISOURCE);
    %[BATHY, TEMPR, SRC, RCV] = lj_oil_plume_env( PEcoor.time);
    %[BATHY, TEMPR, SRC, RCV] = lj_flatline_env( PEcoor.time);
    
%     %simulate bottom instrusion
%     for ix3= 15:19
%         TEMPR.temp(:,:,ix3) = TEMPR.temp(:,:,ix3) + (ix3-14)/5*2;
%     end
    envfilename = sprintf('IW_ENV_%s_%s_s%05d.mat',ISOURCE,...
        datestr(PEcoor.time,'ddmmmyy_HHMMSS'),ix_tw);
    save([envfilepath,envfilename], 'BATHY','TEMPR','SRC','RCV','ISOURCE');
    % Water Depth
    % now only one water depth
    [junk,itmp] = min(sqrt(TEMPR.globalx(:).^2+TEMPR.globaly(:).^2))
    WD = BATHY.z(itmp);
    % -- interpolate sound speeds
    [CAL_GRID_X,CAL_GRID_Y] = meshgrid(TEMPR.PEgridx,TEMPR.PEgridy);
    CAL_GRID_SSPDEPTH = repmat(shiftdim(TEMPR.gridz(:).',-1),[size(CAL_GRID_Y,1) size(CAL_GRID_X,2) 1]);
    tmp_s = 35*ones(size(TEMPR.temp));
    tmp_c = TEMPR.temp;
    tmp_p = CAL_GRID_SSPDEPTH/.995;
    CAL_GRID_SSP = sndspd(tmp_s,tmp_c,tmp_p,'chen');
    % -- SRC to RCV distance
    src2rcvdist = TEMPR.src2rcvdist;
    % -- the following variabiles are going to the 3D acoustic model
    % CAL_GRID_X, CAL_GRID_Y, CAL_GRID_Z, CAL_GRID_SSP
    
    ssp3dfield_filename = sprintf('%sSW50EVT50_3dfield_freq_%d_%s_s%05d.mat',...
        ssp3dfieldpath,freqs,datestr(PEcoor.time,'ddmmmyy_HHMMSS'),ix_tw);
    
    
    save(ssp3dfield_filename,'envfilepath','envfilename','CAL_GRID_X','CAL_GRID_Y',...
        'CAL_GRID_SSP','CAL_GRID_SSPDEPTH','WD' );
    

end

