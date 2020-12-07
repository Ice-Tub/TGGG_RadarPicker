function [geoinfo] = pick_bottom(geoinfo,tp, MinBottomPick)

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

    db_echogram = mag2db(geoinfo.echogram);
    horizontal_mean = mean(db_echogram,2);
    normalized_echogram = db_echogram - horizontal_mean;

    BottomInds = zeros(1,geoinfo.num_trace);
    [~,BottomInds(1)] = max(normalized_echogram(MinBottomPick(1):end,1));
    for n=2:geoinfo.num_trace
        [~,Ind] = findpeaks(normalized_echogram(MinBottomPick(n):end,n),'SortStr','descend','NPeaks',num_bottom_peaks);
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

    dt=geoinfo.time_range(2)-geoinfo.time_range(1);
    t1=geoinfo.time_range(1);
    Bottom_pick_time=(BottomInds*dt)+t1;
    geoinfo.traveltime_bottom=Bottom_pick_time;
end
