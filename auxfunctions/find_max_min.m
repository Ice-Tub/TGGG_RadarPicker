function [lind, p] = find_max_min(opt, data)
%FIND_MAX_MIN Summary of this function goes here
%   Detailed explanation goes here


if opt.find_maxima
    % find local maxima
    [lind,p] = islocalmax(data);
    p = p(lind); 
    lind = find(lind);
    if isempty(lind)
        [~,lind,~,p] = findpeaks(data); 
    end
else
    % find local minima
    [lind,p] = islocalmin(data);
    p = p(lind); 
    lind = find(lind);
    if isempty(lind)
        [~,lind,~,p] = findpeaks(-1*data);  % multiply data with -1 to find its minima
    end
end

end

