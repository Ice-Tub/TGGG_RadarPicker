function [geoinfo] = pick_surface(geoinfo,tp,opt)

% the first maximum should be picked for the surface
    if strcmpi(opt.input_type, 'MCoRDS') 
       
        % choose the first of the first ten maxima
        [~,FirstArrivalInds] = max(geoinfo.data(tp.MinBinForSurfacePick:end,:));
        FirstArrivalInds = floor(movmean(FirstArrivalInds,tp.smooth_sur));
        FirstArrivalInds = FirstArrivalInds+tp.MinBinForSurfacePick;

        geoinfo.twt_sur=ind2twt(geoinfo,FirstArrivalInds);
        
    elseif strcmpi(opt.input_type, 'GPR_LF') || strcmpi(opt.input_type, 'GPR_HF') || strcmpi(opt.input_type, 'awi_flight') || strcmpi(opt.input_type, 'PulsEKKO')
        geoinfo.twt_sur = zeros(1,geoinfo.num_trace);
        disp("Traveltime of surface pick is set to 0.")

%     elseif strcmpi(opt.input_type, 'PulsEKKO')
%      % for each trace, choose the first of 5 maxima as the surface pick
%         for ii = 1:geoinfo.num_trace
%             [~,indPeaks] = findpeaks(geoinfo.data(tp.MinBinForSurfacePick:end, ii), 'NPeaks', 5);
%             correctedInd = indPeaks(1) + tp.MinBinForSurfacePick;
%             geoinfo.twt_sur(ii) = ind2twt(geoinfo, correctedInd);
%         end
%     end



end

 
