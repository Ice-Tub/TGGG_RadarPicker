function [geoinfo] = pick_bottom(geoinfo,echogram,MinBinForBottomPick,smooth2)

   if nargin < 3
    MinBinForBottomPick =   1500;
   end
  
   if nargin < 4
    smooth2 =   200;
   end

[~,FirstArrivalInds] = max(echogram(MinBinForBottomPick:end,:)); 
 FirstArrivalInds = floor(movmean(FirstArrivalInds,smooth2));
 FirstArrivalInds = FirstArrivalInds+MinBinForBottomPick;
 
 dt=geoinfo.time_range(2)-geoinfo.time_range(1);
 t1=geoinfo.time_range(1);
 Bottom_pick_time=(FirstArrivalInds*dt)+t1;
 geoinfo.traveltime_bottom=Bottom_pick_time;
end

 
