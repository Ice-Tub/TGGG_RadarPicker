function save_picks(geoinfo,tp,opt)
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
            layers_relto_surface = geoinfo.layers - surface_ind;
            bottom_relto_surface = bottom_ind - surface_ind;


            layers_topo = layers_relto_surface + binshift;
            bottom_topo = bottom_relto_surface + binshift;

            % these are the final, corrected layers and bottom
            layers_topo_depth = tp.RefHeight - layers_topo * dz;
            bottom_topo_depth = tp.RefHeight - bottom_topo * dz;
            
            geoinfo.layers_relto_surface = layers_relto_surface;
            geoinfo.layers_topo = layers_topo;
            geoinfo.layers_topo_depth = layers_topo_depth;
            
            geoinfo.bottom_relto_surface = bottom_relto_surface;
            geoinfo.bottom_topo = bottom_topo; 
            geoinfo.bottom_topo_depth = bottom_topo_depth;
        end
        
        
        
        geoinfo.num_layer = sum(max(~isnan(geoinfo.layers),[],2));
        geoinfo.tp = tp;
        
        
        save(opt.filename_geoinfo, '-struct', 'geoinfo');
        
        geoinfo.data_org = geoinfo.data;
        data_mean = mean(geoinfo.data_org,2);
        geoinfo.data = geoinfo.data_org-data_mean;
end

