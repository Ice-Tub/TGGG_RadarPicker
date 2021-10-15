function [probabilities] = weigh_peaks(layer, x_trace, lind, p, lmid, leftright, weight_factor)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
%WEIGH_PEAKS Calculates weights to choose which local extremum should be
%chosen. Factors contributing to this are both the previous direction of
%layer propagation and the prominence of the local extrema

% calculate the previous direction of layer propagation and the theoretical
% y_trace following this
trend = layer(x_trace-leftright*1) - layer(x_trace-leftright*2);
predicted_position = lmid + trend;

% calculate the distances of the other positions in the window to the
% predicted one and normalize them
indices_window = 1:2*lmid-1;
distance_to_prediction = abs(indices_window - predicted_position);
normalized_distance = distance_to_prediction./max(distance_to_prediction);

% transform distances so that a high number indicated closeness
dist_select_inverse = 1 - normalized_distance(lind);

normalized_prominence = transpose(p/max(p));

% calculate the weights/probabilities
probabilities = weight_factor*dist_select_inverse + normalized_prominence; 


end

