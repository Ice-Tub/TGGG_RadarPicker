function makecolorthresh(geoinfo,sy,sx)

for i=1:74345;
peakval(i,1)=mag2db(geoinfo.FlatData(sy(i,1),sx(i,1)));
end

maxp=max(peakval);
minp=min(peakval);

%color = hot(74345);
for n = 1:74345
  TempScaled(n,1) = (peakval(n) - minp) / (maxp - minp);
end

%scatter(sx, sy, 20, TempScaled, '*');
thresholds = [20, 40];
% Assign color
colorID = zeros(length(peakval),3);     % default is black
colorID(peakval < thresholds(1),3) = 1; %blue
colorID(peakval> thresholds(2),1) = 1; %red
%end
