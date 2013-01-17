clear
envdir = '../mat/env/';
envfiles = dir([envdir,'*.mat']);
for ix=1:length(envfiles)
    load([envdir,envfiles(ix).name]);
    clf
     imagesc(TEMPR.temp(:,:,4))
     set(gca,'clim',[18 26]);
     pause
end