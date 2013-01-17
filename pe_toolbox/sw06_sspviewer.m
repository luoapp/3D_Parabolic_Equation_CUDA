%TS = SSPatNRL300;
%TS = SSPatSHARK;
TS = SSPatSW32;
clf
for ix=1:size(TS.SENSOR_DEPTH,1)
    ix1 = find((TS.JDVEC<=datenum([2006 8 17 23 0 0]) ).* ...
        (TS.JDVEC>=datenum([2006 8 17 20 0 0]) ));
    %plot(TS.JDVEC(ix1),TS.T(ix,ix1))
    plot(TS.T(ix,ix1))
    %set(gca,'xlim',datenum([2006 8 17 20 0 0])+[0 3/24]);
    set(gca,'ylim',[5 25])
    %datetick('x','keeplimits')
    ix
    pause
end