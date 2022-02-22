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
            layers_relto_surface = geoinfo.layers - surface_ind;
            bottom_relto_surface = bottom_ind - surface_ind;

            
            geoinfo.layers_relto_surface = layers_relto_surface;
            geoinfo.bottom_relto_surface = bottom_relto_surface;

            % layers relative to surface in twt
            layers_twt = layers_relto_surface * dt;
            geoinfo.layers_twt = layers_twt;

            % add  layers to metadata
           metadata.layer_twt = layers_twt;
           
        end
        
        %compute interruptions in layer for metadata and save layer
        for ii = 1:opt.nol
            metadata.interruptions{ii} = compute_interruption(geoinfo.layers(ii,:));
        end
        metadata.layer = geoinfo.layers;
        
        geoinfo.num_layer = sum(max(~isnan(geoinfo.layers),[],2));
        geoinfo.tp = tp;

       
        
        save(opt.filename_geoinfo, '-struct', 'geoinfo');
        save_metadata(opt, metadata)

        geoinfo.data_org = geoinfo.data;
        data_mean = mean(geoinfo.data_org,2);
        geoinfo.data = geoinfo.data_org-data_mean;
end

