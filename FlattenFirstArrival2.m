function [geoinfo] = FlattenFirstArrival2(geoinfo, MinBinForSurfacePick)
    
    [~,FirstArrivalInds] = max(geoinfo.echogram(MinBinForSurfacePick:end,:));
    smoothflat=10;
    FirstArrivalInds = floor(movmean(FirstArrivalInds,smoothflat)+MinBinForSurfacePick);
    
    %Pull them up
    geoinfo.FlatData = geoinfo.echogram*0;
    % %load size of new and old matrix (Height and Width) 
    [Height, Width] = size(geoinfo.echogram);
    % %for whole width calculate each column
    for k = 1:Width
        % %fill matrix for total height from ice surface to bottom with
        % %original data values while ice surface is at top of matrix
        % %,k=for column k
        geoinfo.FlatData(1:Height-FirstArrivalInds(k)+1,k) = geoinfo.echogram(FirstArrivalInds(k):end,k);
    end
end