function [filt_data] = movmedian_2d(data, window)
%MOVMEDIAN_2D Summary of this function goes here
%   Detailed explanation goes here

if mod(window, 2) == 0
    window = window + 1;
end

half_window = floor(window/2);
filt_data = zeros(size(data));
n_window = window*window;

for ii = ceil(window/2):size(data,1)-half_window
    for jj = ceil(window/2):size(data,2)-half_window
        x_ind = (jj-half_window):(jj+half_window);
        y_ind = (ii-half_window):(ii+half_window);
        partial_data = data(y_ind,x_ind);
        linearized = reshape(partial_data, [1, n_window]);
        filt_data(ii,jj) = median(linearized);
    end
end



    
end

