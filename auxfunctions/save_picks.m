function save_picks(geoinfo,tp,opt)
%SAVE_PICKS Summary of this function goes here
%   Detailed explanation goes here
        if isfield(geoinfo,'data_org')
            geoinfo.data = geoinfo.data_org;
            geoinfo = rmfield(geoinfo,'data_org');
        end

        % Compute additional geoinfo fields
        
        dt = geoinfo.twt(2)-geoinfo.twt(1); % time step (for traces)
        dz = dt/2*1.68e8;
        time_surface = geoinfo.twt_sur-geoinfo.twt(1);
        surface_ind = round(time_surface/dt);
        binshift = round((tp.RefHeight - geoinfo.elevation_sur)/dz);
        
        layers_relto_surface = geoinfo.layers - surface_ind;
        layers_topo = layers_relto_surface + binshift;
        layers_topo_depth = tp.RefHeight - layers_topo * dz;
        
        geoinfo.num_layer = sum(max(~isnan(geoinfo.layers),[],2));
        geoinfo.layers_relto_surface = layers_relto_surface;
        geoinfo.layers_topo = layers_topo;
        geoinfo.layers_topo_depth = layers_topo_depth;
        geoinfo.tp = tp;
        save(opt.filename_geoinfo, '-struct', 'geoinfo');
        
        geoinfo.data_org = geoinfo.data;
        data_mean = mean(geoinfo.data_org,2);
        geoinfo.data = geoinfo.data_org-data_mean;
end

