function [Data] = FlattenFirstArrival1(Data, MinBinForSurfacePick)
    
    %Pick First Arrival and Flatten for Topo Correction
    % FirstArrival: max value
    % FirstArrivalInds: position of max value
    % MinBinForSurfacePick: choosen start position to cancel first interferences out
    
 % %explain MinBinSurfacePick; default value = 1000
   if nargin < 2
    MinBinForSurfacePick =   1000;
  end
  
    [~,FirstArrivalInds] = max(Data.Data(MinBinForSurfacePick:end,:));
    
    %Some smoothing to make it not too wiggely
    % %floor: rounds element to nearest intger less o equal
    % %movmean: mean calc over sliding window of length (here=30) across
    % % %neighbouring element.
    FirstArrivalInds = floor(movmean(FirstArrivalInds,10)+MinBinForSurfacePick);
    
    %Pull them up
    % %set empty matrix with size of Data
    Data.FlatData = Data.Data*0;
    % %load size of new and old matrix (Height and Width) 
    [Height, Width] = size(Data.Data);
    % %for whole width calculate each column
    for k = 1:Width
        % %fill matrix for total height from ice surface to bottom with
        % %original data values while ice surface is at top of matrix
        % %,k=for column k
        Data.FlatData(1:Height-FirstArrivalInds(k)+1,k) = Data.Data(FirstArrivalInds(k):end,k);
    end
end