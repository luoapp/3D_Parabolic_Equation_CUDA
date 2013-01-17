clear
%remove the small IW before ev50
load ..\runSW06_UDELevent50\EVENT50_3DENV\SSPatNRL300.mat
load ..\runSW06_UDELevent50\EVENT50_3DENV\SSPatSHARK.mat
load ..\runSW06_UDELevent50\EVENT50_3DENV\SSPatSW32.mat


TS = SSPatSHARK;
d = [150 178 20;
    147 176 19;
    148 172 14;
    148 168 10;
    149 169 9];
s = [6:10];
clf
for ix=s
    ix1 = find((TS.JDVEC<=datenum([2006 8 17 23 0 0]) ).* ...
        (TS.JDVEC>=datenum([2006 8 17 20 0 0]) ));
    %plot(TS.JDVEC(ix1),TS.T(ix,ix1))
    plot(TS.T(ix,ix1))
    hold on;
    %set(gca,'xlim',datenum([2006 8 17 20 0 0])+[0 3/24]);
    TS.T(ix,ix1(1)-1+[d(ix-s(1)+1,1):d(ix-s(1)+1,2)])=d(ix-s(1)+1,3);
    plot(TS.T(ix,ix1),'r')
    
    set(gca,'ylim',[5 25])
    %datetick('x','keeplimits')
    ix
    pause
end
SSPatSHARK = TS;
save('SSPatSHARK_IWremoved.mat','SSPatSHARK');

TS = SSPatNRL300;
d = [146 171 18;
    156 156 17.36;
    150 169 11];
s = [7 :9];
clf
for ix=s
    ix1 = find((TS.JDVEC<=datenum([2006 8 17 23 0 0]) ).* ...
        (TS.JDVEC>=datenum([2006 8 17 20 0 0]) ));
    %plot(TS.JDVEC(ix1),TS.T(ix,ix1))
    plot(TS.T(ix,ix1))
    hold on;
    %set(gca,'xlim',datenum([2006 8 17 20 0 0])+[0 3/24]);
    TS.T(ix,ix1(1)-1+[d(ix-s(1)+1,1):d(ix-s(1)+1,2)])=d(ix-s(1)+1,3);
    plot(TS.T(ix,ix1),'r')
    
    set(gca,'ylim',[5 25])
    %datetick('x','keeplimits')
    ix
    pause
end
SSPatNRL300 = TS;
save('SSPatNRL300_IWremoved.mat','SSPatNRL300');



TS = SSPatSW32;
d = [153 208 11];
s = [8];
clf
for ix=s
    ix1 = find((TS.JDVEC<=datenum([2006 8 17 23 0 0]) ).* ...
        (TS.JDVEC>=datenum([2006 8 17 20 0 0]) ));
    %plot(TS.JDVEC(ix1),TS.T(ix,ix1))
    plot(TS.T(ix,ix1))
    hold on;
    %set(gca,'xlim',datenum([2006 8 17 20 0 0])+[0 3/24]);
    TS.T(ix,ix1(1)-1+[d(ix-s(1)+1,1):d(ix-s(1)+1,2)])=d(ix-s(1)+1,3);
    plot(TS.T(ix,ix1),'r')
    
    set(gca,'ylim',[5 25])
    %datetick('x','keeplimits')
    ix
    pause
end
SSPatSW32 = TS;
save('SSPatSW32_IWremoved.mat','SSPatSW32');

