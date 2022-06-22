function [interruption] = compute_interruption(layer)
%COMPUTE_INTERRUPTION Creates array which contains 1 at positions where
%picked layer is interrupted, otherwise it contains 0
logArr = ~isnan(layer);
interruption = zeros(size(layer));

% if NaN occurs at a position where picked layer can be found at both sides
% of it, it is considered an interruption. However, an interruption is only
% valid if it continues for more than 10 pixel
for ii = 2:length(layer)-1
    if isnan(layer(ii))
        if sum(logArr(1:ii-1)) > 0 && sum(logArr(ii+1:end)) > 0
            interruption(ii) = 1;
        end
    end

end

% calculate how many interruptions occur (only if they are longer than 10
% pixel)

limitInterruption = 10;
count = 0;
numberOfInterruptions = 0;

if sum(interruption) > limitInterruption

    indInterruption = find(interruption);
    currentInd = indInterruption(1);

    for kk = 1:length(indInterruption)
        if currentInd == indInterruption(kk)
            count = count + 1;
            currentInd = indInterruption(kk) + 1;
        else
            if count > limitInterruption
                numberOfInterruptions  = numberOfInterruptions + 1;
                count = 1;
                currentInd = indInterruption(kk) + 1;
            else
                count = 1;
                currentInd = indInterruption(kk) + 1;
            end
    
        end
    
    end

    if count > limitInterruption
        numberOfInterruptions = numberOfInterruptions + 1;
    end

end

% only save number of interruptions if the layer has any picked data
if ~sum(logArr) == 0
    interruption = strcat(string(numberOfInterruptions), ' interruption(s)');
else
    interruption = "not picked";
end

end

