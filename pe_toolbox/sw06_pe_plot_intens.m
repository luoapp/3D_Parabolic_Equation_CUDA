clear 
matdir = '../mat/';
envdir = [matdir, 'env/'];
envfiles = dir([envdir,'SW50EVT50_ENV*.mat']);

pedir = [matdir, 'pe_result/'];
pefiles = dir([pedir, '*.mat']);

figure;
for ix = 1:length(pefiles)
    clf
    info = sw06_pe_matfileinfo(pefiles(ix).name);
    load([pedir,pefiles(ix).name])

end


contour_vec = [ 70:2.5:90];
 contour_vec = [80 80];
c_axis = [18 25];
figure;
for ix = 1:length(files)
    clf
    info = sw06_pe_envinfo(files(ix).name);
    load([envdir,files(ix).name])
    [tx, ty] = meshgrid(TEMPR.PEgridx,TEMPR.PEgridy);
    pcolor(tx/1000,ty/1000,TEMPR.temp(:,:,4))
    shading flat
    hold on
    contour(BATHY.x/1000, BATHY.y/1000, BATHY.z, contour_vec,'w')
    caxis(c_axis)
    set(gca,'dataAspectRatio',[1 1 1]);
    pause
end