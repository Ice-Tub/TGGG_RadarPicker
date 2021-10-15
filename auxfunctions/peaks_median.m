function [lind, p] = peaks_median(opt, geoinfo, current_window, x_trace)
%PEAKS_MEDIAN Summary of this function goes here
%   Detailed explanation goes here


%IST HIER DER WINDOW SHIFT PROBLEMATISCH?
median_window = zeros(length(current_window),1);
bound = floor(length(current_window)/2);
    


for i = 1:length(current_window)
    
    % adapt window at the edges of radargram (boundary conditions)
    if x_trace <= bound 
        clm_ind = 1:x_trace + bound;
    elseif x_trace > size(geoinfo.data,2)-bound
        clm_ind = x_trace-bound:size(geoinfo.data,2);
    else
        clm_ind = x_trace-bound:x_trace+bound;
    end
    
        
    if current_window(i) <= bound
        row_ind = current_window(i):current_window(i)+bound;
    elseif current_window(i) > size(geoinfo.data,1) - bound
        row_ind = current_window(i)-bound:current_window(i);
    else
        row_ind = current_window(i)-bound:current_window(i)+bound;
    end
    
    % choose rectangular window
    data_select = geoinfo.data(row_ind, clm_ind);   
    
    % calculate median of window and assign it to ith element
    median_window(i) = median(data_select(:)); 
end

% find indices of either local maxima or minima
[lind,p] = find_max_min(opt, median_window);


end

