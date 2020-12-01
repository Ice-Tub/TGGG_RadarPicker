function [geoinfo] = pick_bottom(geoinfo,MinBinForBottomPick,smooth2)

    if nargin < 2
        MinBinForBottomPick =   1500;
    end

    if nargin < 3
    smooth2 =   200;
    end

    db_echogram = mag2db(geoinfo.echogram);
    horizontal_min = min(db_echogram,[],2);    
    normalized_echogram = db_echogram - horizontal_min;
   
    [~,FirstArrivalInds] = max(normalized_echogram(MinBinForBottomPick:end,:)); 
    %figure(4)
    %imagesc(normalized_echogram)
    %figure(5)
    %plot(1:length(horizontal_min),horizontal_min)
   
    FirstArrivalInds = floor(movmean(FirstArrivalInds,smooth2));
    FirstArrivalInds = FirstArrivalInds+MinBinForBottomPick;

    dt=geoinfo.time_range(2)-geoinfo.time_range(1);
    t1=geoinfo.time_range(1);
    Bottom_pick_time=(FirstArrivalInds*dt)+t1;
    geoinfo.traveltime_bottom=Bottom_pick_time;
end

 
