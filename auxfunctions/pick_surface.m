function [geoinfo] = pick_surface(geoinfo,tp,opt)

% the first maximum should be picked for the surface
    if strcmpi(opt.input_type, 'MCoRDS') 
       
        % choose the first of the first ten maxima
        [~,FirstArrivalInds] = max(geoinfo.data(tp.MinBinForSurfacePick:end,:));
        FirstArrivalInds = floor(movmean(FirstArrivalInds,tp.smooth_sur));
        FirstArrivalInds = FirstArrivalInds+tp.MinBinForSurfacePick;

        geoinfo.ind_sur = FirstArrivalInds;
        geoinfo.twt_sur = ind2twt(geoinfo, geoinfo.ind_sur);
    else
        % Assign first bin as surface
        geoinfo.ind_sur = ones(1,geoinfo.num_trace);
        geoinfo.twt_sur = ind2twt(geoinfo, geoinfo.ind_sur);
        disp("Traveltime of surface pick is set to 0.")
    end


end

 
