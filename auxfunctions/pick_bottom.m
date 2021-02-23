function [geoinfo] = pick_bottom(geoinfo, tp, opt, MinBottomPick, MaxBottomPick)

    smooth2 = tp.smooth_bot;
    num_bottom_peaks = tp.num_bottom_peaks;

    %if nargin < 2
    %    MinBinForBottomPick =   1500;
    %end

    %if nargin < 3
    %smooth2 =   200;
    %end

    %if nargin < 4
    %    num_bottom_peak = 5;
    %end
    
    if strcmpi(opt.input_type, 'MCoRDS')
        db_data = mag2db(geoinfo.data);
    elseif strcmpi(opt.input_type, 'GPR_LF')
        db_data = geoinfo.data;
    end
    horizontal_mean = mean(db_data,2);
    normalized_data = db_data - horizontal_mean;

    BottomInds = zeros(1,geoinfo.num_trace);
    [~,BottomInds(1)] = max(normalized_data(MinBottomPick(1):MaxBottomPick,1));
    for n=2:geoinfo.num_trace
        [~,Ind] = findpeaks(normalized_data(MinBottomPick(n):MaxBottomPick,n),'SortStr','descend','NPeaks',num_bottom_peaks);
        [~, pos] = min(abs(Ind-BottomInds(n-1)));
        BottomInds(n) = Ind(pos);
    end

    %[~,FirstArrivalInds] = max(normalized_echogram(MinBinForBottomPick:end,:));
    %figure(4)
    %imagesc(normalized_echogram)
    %figure(5)
    %plot(1:length(horizontal_min),horizontal_min)

    %FirstArrivalInds = floor(movmean(FirstArrivalInds,smooth2));
    BottomInds = BottomInds+MinBottomPick;

    dt=geoinfo.twt(2)-geoinfo.twt(1);
    t1=geoinfo.twt(1);
    Bottom_pick_time=(BottomInds*dt)+t1;
    geoinfo.traveltime_bottom=Bottom_pick_time;
end
