function [geoinfo] = pick_bottom(geoinfo, tp, opt, MinBottomPick, MaxBottomPick)
    
    if strcmpi(opt.input_type, 'MCoRDS')
        data_scaled = mag2db(geoinfo.data);
    elseif strcmpi(opt.input_type, 'GPR_LF')
        data_scaled = geoinfo.data;
    end
    
    horizontal_mean = mean(data_scaled,2);
    normalized_data = data_scaled - horizontal_mean;

    BottomInds = zeros(1,geoinfo.num_trace);
    [~,BottomInds(1)] = max(normalized_data(MinBottomPick(1):MaxBottomPick,1));
    for n=2:geoinfo.num_trace
        [~,Ind] = findpeaks(normalized_data(MinBottomPick(n):MaxBottomPick,n),'SortStr','descend','NPeaks',tp.num_bottom_peaks);
        [~, pos] = min(abs(Ind-BottomInds(n-1)));
        BottomInds(n) = Ind(pos);
    end

    BottomInds = floor(movmean(BottomInds,tp.smooth_bot));
    BottomInds = BottomInds + MinBottomPick;
    
    geoinfo.twt_bot = ind2twt(geoinfo,BottomInds);
end
