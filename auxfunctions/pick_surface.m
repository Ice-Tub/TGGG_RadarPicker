function [geoinfo] = pick_surface(geoinfo,tp,opt)

    if strcmpi(opt.input_type, 'MCoRDS')
        [~,FirstArrivalInds] = max(geoinfo.data(tp.MinBinForSurfacePick:end,:));
        FirstArrivalInds = floor(movmean(FirstArrivalInds,tp.smooth_sur));
        FirstArrivalInds = FirstArrivalInds+tp.MinBinForSurfacePick;

        geoinfo.twt_sur=ind2twt(geoinfo,FirstArrivalInds);
    elseif strcmpi(opt.input_type, 'GPR_LF')
        geoinfo.twt_sur = zeros(1,geoinfo.num_trace);
        disp("Traveltime of surface pick for GPR_LF data is set to 0.")
    end
end

 
