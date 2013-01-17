
function [H,dH,d2H] = sw06_pe_sub_mixing_function_rho(eta,Lrho)
% cubic spline smoothing function is used
% 
ieta1 =                  (eta<=-Lrho);
ieta2 = (eta>=-Lrho)  &  (eta<=-Lrho/2);
ieta3 = (eta>=-Lrho/2) & (eta<=Lrho/2);
ieta4 = (eta>=Lrho/2) &  (eta<=Lrho);
ieta5 = (eta>=Lrho);

H = nan(size(eta));
H(ieta1) = 0;
H(ieta2) = 2/3*(1+eta(ieta2)/Lrho).^3;
H(ieta3) = 1/2 + eta(ieta3)/Lrho -2/3*(eta(ieta3)/Lrho).^3;
H(ieta4) = 1-2/3*(1-eta(ieta4)/Lrho).^3;
H(ieta5) = 1;
dH = nan(size(eta));
dH(ieta1) = 0;
dH(ieta2) = 2/Lrho*(1+eta(ieta2)/Lrho).^2;
dH(ieta3) = 1/Lrho*(1-2*(eta(ieta3)/Lrho).^2);
dH(ieta4) = 2/Lrho*(1-eta(ieta4)/Lrho).^2;
dH(ieta5) = 0;

d2H = nan(size(eta));
d2H(ieta1) = 0;
d2H(ieta2) = 4/Lrho/Lrho*(1+eta(ieta2)/Lrho);
d2H(ieta3) = -4/Lrho/Lrho*(eta(ieta3)/Lrho);
d2H(ieta4) = -4/Lrho/Lrho*(1-eta(ieta4)/Lrho);
d2H(ieta5) = 0;

return