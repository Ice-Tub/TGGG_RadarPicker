function save_bottom(geoinfo,tp,opt)
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
        surface_ind = geoinfo.ind_sur;
        bottom_ind = geoinfo.ind_bot;
        
        
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
        end
        
        geoinfo.tp = tp;
        save(opt.filename_geoinfo, '-struct', 'geoinfo');
end

