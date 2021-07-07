function [var_twt] = ind2twt(geoinfo,var_ind)
%IND2TWT transform variables given by index into twt signal.
%   Detailed explanation goes here
    dt = geoinfo.twt(2)-geoinfo.twt(1);
    t1 = geoinfo.twt(1);
    var_twt = (var_ind*dt)+t1;
end

