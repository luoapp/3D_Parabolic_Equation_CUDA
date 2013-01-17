clear;

source = 'NRL300';
%source = 'UDelJ15';

% if strcmpi(source,'nrl300')
%     matdir = '..\mat\';
% else
%     error('unknown source!');
% end
matdir = 'D:\Jing\pe_NRL300_broadband_horizontal_beamforming\cuda\mat\'; %use absolute path
fieldfiledir = [matdir,'3d_field\'];
envfilepath = [matdir, 'env\'];
cudafiledir = [matdir,'cuda\'];
peresultpath = [matdir,'pe_result\'];
peresultpathbin = [peresultpath,'bin\'];




fieldfiles=dir([fieldfiledir,'*.mat']);

!del gpu*.bat
runfile1 = 'gpu0.bat';
runfile2 = 'gpu1.bat';
eval(['!echo @echo off  >>',runfile2]);
eval(['!echo @echo off  >>',runfile1]);
ix_gpu=0;
for ix=1:length(fieldfiles)
    %     if ~strcmpi('SW50EVT50_3dfield_freq_250_17Aug06_214000_s01.mat',fieldfiles(ix).name)
    %         continue;
    %     end
    
    %     if(fieldfiles(ix).bytes < 1e6)
    %         continue;
    %     end
    load([fieldfiledir,fieldfiles(ix).name]);
    
    load([envfilepath,envfilename]);
    
    if exist('ISOURCE','var')
        if ~strcmpi(ISOURCE, source)
            error('unknown source!');
        elseif strcmpi(ISOURCE, 'udelj15')
            flag_j15_memerror = 1;
            if flag_j15_memerror == 1
                j15_rcvr_dist = TEMPR.src2rcvdist - 2000;
            end
        end
    end
    
    src2rcvdist = TEMPR.src2rcvdist;
    
    parastr =  fieldfiles(ix).name(end-9:end-4);
    
    
    %freq = str2num(fieldfiles(ix).name(24:26));
    for freq = [270:330]
        f0 = freq ; % Hz
        c0 = 1500;
        lambda0=c0/f0;
        
        if strcmpi('UDelJ15',ISOURCE)
            rng=j15_rcvr_dist;% unit: m. rng specifies the _REAL_ source receiver distance. it can be different then src2rcvdist, and use it to avoid memory error in some cases.
        elseif strcmpi('nrl300',ISOURCE)
            rng = src2rcvdist-2000; % -2000 to account the NRL300 memerror.
            
        else
            error('unknown source!');
        end
        
        % Starter_type = 'Gaussian''s';
        % Starter_type = 'Greene''s';
        Starter_type = 'Thomson''s';
        % - x
        steplamb=1;
        ndxout=4;
        % - y
        ny=2^12;
        %ny = ny*2; %modified for broader IW observing
        numperlambday=5;
        wid = ny*lambda0/numperlambday;  % horizontal width
        % - z
        nz=2^8; numperlambdaz=4;
        aspect = wid/(nz*lambda0/numperlambdaz);  % y-to-z ratio
        
        Lrho = 2*c0/f0; % default number 2*lambda0
        Lc = c0/f0/10;  % default number lambdo0/10
        PEcoor.time=datenum(fieldfiles(ix).name(28:41),'ddmmmyy_HHMMSS');
        steplength=steplamb*lambda0;
        numstep=round(rng/steplength);
        
        range=steplength*numstep;
        icase = 'event50';
        ys=  0 ;
        
        zs=WD-10;
        outfile = sprintf('%sSW50EVT50_%s_3DWAPE_freq_%d_%s_%s.mat',peresultpath,...
            icase,freq,datestr(PEcoor.time,'ddmmmyy_HHMMSS'), parastr);
        filename = [cudafiledir,'freq',num2str(freq),'_', datestr(PEcoor.time,'ddmmmyy_HHMMSS_'),parastr,'_cuda.mat'];
        ssp3dfield_filename=[fieldfiledir,fieldfiles(ix).name];
        gpu = mod(ix,2);
        ix_gpu=ix_gpu+1;
        ix_gpu = mod(ix_gpu,2);
        %gpu = 1;
        if ix_gpu == 1
            %   continue;
        end
        
        flag_psivol = 0;  %calculate volumetric psi. Great amount of data
        flag_Ez = 1;      %calculate depth-integrated intensity, i.e., topview
        flag_Ez_hla = 1;  %calculate intensity ( psi.^2) at sea floor for hla simulation
        flag_psifinal = 1; %calcuate psi at receiver
        flag_psifinal_bin = 0; %psifinal as in bin file
        
        psifinal_bin_filename = sprintf('%sSW50EVT50_%s_3DWAPE_freq_%d_%s_%s_psi.bin',peresultpathbin,...
            icase,freq,datestr(PEcoor.time,'ddmmmyy_HHMMSS'), parastr);
        
        
        
        save(filename, 'ny', 'nz','numstep','freq','c0','ssp3dfield_filename','wid',...
            'steplength','aspect','Starter_type','zs','ys','ndxout','Lrho','Lc','outfile','gpu',...
            'flag_psivol', 'flag_Ez', 'flag_Ez_hla', 'flag_psifinal', 'flag_psifinal_bin',...
            'psifinal_bin_filename');
        
        if (ix_gpu==0)
            eval(['!echo 3dpe_cu_f.exe ',filename,' >>',runfile1]);
        else
            eval(['!echo 3dpe_cu_f.exe ',filename,' >>',runfile2]);
        end
    end
end

!move gpu*.bat d:\jing\matlib\bin\
