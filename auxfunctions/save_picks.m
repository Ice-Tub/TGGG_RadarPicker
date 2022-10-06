function save_picks(geoinfo,metadata,tp,opt)
%SAVE_PICKS Summary of this function goes here
%   Detailed explanation goes here
        if isfield(geoinfo,'data_org')
            geoinfo.data = geoinfo.data_org;
            geoinfo = rmfield(geoinfo,'data_org');
        end

        % Compute additional geoinfo fields
        
        dt = geoinfo.twt(2)-geoinfo.twt(1); % time step (for traces)
        dz = dt/2*tp.ice_velocity;
        ns = size(geoinfo.data,1);
        nt = size(geoinfo.data,2);
        time_surface = geoinfo.twt_sur - geoinfo.twt(1);
        time_bottom = geoinfo.twt_bot - geoinfo.twt(1);
        surface_ind = round(time_surface/dt);
        bottom_ind = round(time_bottom/dt);
        
        
        if ~strcmpi(opt.input_type, 'awi_flight')
            binshift = round((tp.RefHeight - geoinfo.elevation_sur)/dz);


            if isfield(geoinfo, 'data_elevation')
                for kk=1:nt
                    %This is computationally bad but so convenient. 
                    %Matlab will adjust matrix size.
                    geoinfo.data_elevation(binshift(kk):binshift(kk)+(ns-surface_ind),kk) = geoinfo.data(surface_ind:end,kk);
                end

                nsc = size(geoinfo.data_elevation,1);

                % compute elevation vector
                geoinfo.elevation = tp.RefHeight - dz*(1:nsc)'+dz;
            end


            % adapt layers and bottom pick to topography
            layers_relto_surf = geoinfo.layers - surface_ind;
            bottom_relto_surf = bottom_ind - surface_ind;

            
            geoinfo.layers_relto_surf = layers_relto_surf;
            geoinfo.bottom_relto_surf = bottom_relto_surf;

            % layers relative to surface in twt
            layers_relto_surf_twt = layers_relto_surf * dt;
            geoinfo.layers_relto_surf_twt = layers_relto_surf_twt;

            % add layers, surface and bottom pick to metadata
            metadata.IRH_relto_surf_twt = layers_relto_surf_twt;
            metadata.IRH_relto_surf_bin = layers_relto_surf;

            metadata.surface_bin = surface_ind;
            metadata.surface_twt = time_surface;

            metadata.bottom_relto_surf_twt = bottom_relto_surf * dt;
            metadata.bottom_relto_surf_bin = bottom_relto_surf;

            metadata.bottom_bin = bottom_ind;
            metadata.bottom_twt = time_bottom;
        end
        
      
        
        geoinfo.num_layer = sum(max(~isnan(geoinfo.layers),[],2));
        geoinfo.tp = tp;
        
        save(opt.filename_geoinfo, '-struct', 'geoinfo');
        save_metadata(opt, geoinfo, metadata)
end

