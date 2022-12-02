function [geoinfo] = pick_bottom(geoinfo, tp, opt, MinBottomPick, MaxBottomPick)
% PICK_BOTTOM handles the picking of the bottom reflector.
%   

if opt.exist_bottom
    geoinfo.data

    if strcmpi(opt.input_type, 'MCoRDS')
        data_scaled = mag2db(geoinfo.data);
    elseif strcmpi(opt.input_type, 'GPR_LF') || strcmpi(opt.input_type, 'PulsEKKO')
        data_scaled = geoinfo.data;
    end
    
    horizontal_mean = mean(geoinfo.data,2);
    normalized_data = geoinfo.data - horizontal_mean;

    BottomInds = zeros(1,geoinfo.num_trace);
    [~,BottomInds(1)] = max(normalized_data(MinBottomPick(1):MaxBottomPick(1),1));
    for n=2:geoinfo.num_trace
        [~,Ind] = findpeaks(normalized_data(MinBottomPick(n):MaxBottomPick(n),n),'SortStr','descend','NPeaks',tp.num_bottom_peaks);
        [~, pos] = min(abs(Ind-BottomInds(n-1)));
        BottomInds(n) = Ind(pos);
    end

    BottomInds = floor(movmean(BottomInds,tp.smooth_bot));
    BottomInds = BottomInds + MinBottomPick;
        
    geoinfo.ind_bot = BottomInds;
    geoinfo.twt_bot = ind2twt(geoinfo,BottomInds);

else % No bottom reflector exists in data.
    geoinfo.ind_bot = NaN(1,geoinfo.num_trace);
    geoinfo.twt_bot = NaN(1,geoinfo.num_trace);
end

end
