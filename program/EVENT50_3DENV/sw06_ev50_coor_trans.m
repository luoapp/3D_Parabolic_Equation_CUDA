function O= sw06_ev50_coor_trans(in)
%transform to the IW coordinate
%1)rotate 2)translate
persistent theta c s;
origin = [ 0 0]; %shark VLA
%O.coor = [cos(in.theta), -sin(in.theta); sin(in.theta), cos(in.theta)]*[in.x in.y]';
try
    t1 = in.speed;
catch
    in.speed = 0;
    in.t=0;
end
if isempty(theta) || theta ~= in.theta
    theta = in.theta;
    c = cos(in.theta);
    s = sin(in.theta);
end
X = c*in.x - s*in.y + in.speed*in.t;
Y = s*in.x + c*in.y + 0*in.t;

O.x=X;
O.y=Y;


