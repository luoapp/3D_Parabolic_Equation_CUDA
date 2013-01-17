clear
%calculate hla received signal from psi

load('hla.mat');
[pe1.geotime ixgt]=sort(pe.geotime);
pe1.x = pe.x(ixgt);
pe1.y1 = pe.y1(ixgt);
pe1.y2 = pe.y2(ixgt);
pe1.intens1 = pe.intens1(ixgt);
pe1.intens2 = pe.intens2(ixgt);


shark_hla = sw06_rcvr_config('shark_hla');
[ shark_hla.x shark_hla.y] = sw06_sph2grid3(shark_hla.location(:,1),shark_hla.location(:,2));
shark_hla.dist = (shark_hla.x .^2 + shark_hla.y .^2).^0.5;
gt = diff(pe1.geotime);
ix2 = find(gt>0);
for ix=0:length(ix2)
    if ix==0
        n1 = 1;
    else
        n1 = ix2(ix)+1;
    end
    
    if ix == length(ix2)
        n2 = length(pe1.geotime);
    else
        n2 = ix2(ix+1);
    end
    intens1(:,ix+1) = interp1((pe1.x(n1:n2).^2 + pe1.y1(n1:n2).^2).^0.5, pe1.intens1(n1:n2),...
        shark_hla.dist);
    intens2(:,ix+1) = interp1((pe1.x(n1:n2).^2 + pe1.y2(n1:n2).^2).^0.5, pe1.intens2(n1:n2),...
        shark_hla.dist);
    
    
end
geotime = [pe1.geotime(ix2) pe1.geotime(end)];
imagesc(geotime, shark_hla.dist,intens2);
datetick
axis tight

set(gca,'fontsize',12,'fontweight','bold');
ylabel('depth(m)');
xlabel('Geotime');
title(['Received signal on Shark HLA during J15 M3 transmission']);
print('-dpng',['SW06_PE_J15_M3_HLA.png']);
