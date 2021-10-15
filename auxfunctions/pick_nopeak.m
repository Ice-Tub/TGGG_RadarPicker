function [y_trace] = pick_nopeak(layer, x_trace, current_window, leftright, nopeaks_window)
%PICK_NOPEAK Calculates how the layer is propagated in case there is no
%local extremum in intensity


lmid = round(length(current_window)/2);


if x_trace > (nopeaks_window + 1) && x_trace < (length(layer) - nopeaks_window)
    
    trend = 0;
    count = 0;
    
    % compute the average direction of layer propagation within the last
    % traces (number of averaged traces given by nopeaks_window)
    for i = 1:nopeaks_window
        update = layer(x_trace-leftright*i) - layer(x_trace-leftright*(i+1));
        if ~isnan(update)
            trend = trend + update;
            count = count + 1; 
        end
    end
    
    if count ~= 0
        trend = round(trend/count);
    else
        trend = 0;
    end
    

    % compute y-trace assuming that the direction of layer propagation is
    % the one computed above
    predicted_position = lmid + trend;

    if predicted_position < 1
        predicted_position = 1;
    elseif predicted_position > length(current_window)
        predicted_position = length(current_window);
    end

    y_trace = current_window(predicted_position);
    
else
    y_trace = current_window(lmid);

    
end

end

