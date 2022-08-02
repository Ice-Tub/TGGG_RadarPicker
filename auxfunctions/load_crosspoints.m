function [metadata, cp_idx,cp_layers] = load_crosspoints(geoinfo, metadata, opt)
%LOAD_CROSSPOINTS Summary of this function goes here
%   Detailed explanation goes here
    cp_idx = NaN;
    cp_layers = NaN(opt.nol,1);

    for k = 1:opt.n_cross
        geoinfo_co = load(opt.filenames_cross{k}); % Loading the cross-over file
        
        if ~isfield(geoinfo_co,'version')
            geoinfo_co = update_geoinfo(geoinfo_co);
        end

        if ~isfield(geoinfo_co,'psX') % Check if polar stereographic coordinates not exist in file
            [geoinfo_co.psX,geoinfo_co.psY] = ll2ps(geoinfo_co.latitude,geoinfo_co.longitude); %convert to polar stereographic
        end

        P = [geoinfo.psX; geoinfo.psY]';
        P_co= [geoinfo_co.psX; geoinfo_co.psY]';
        [points_dist,dist] = dsearchn(P,P_co);

        [val_dist, pos_dist] = min(dist);

        distthresh  = 120;  % Maximal allowed distance between cross- or neighbour-points.
        if val_dist < distthresh
            geoinfo_co_idx = pos_dist; 
            geoinfo_idx = points_dist(pos_dist);
            [~,nameCO,~] =fileparts(opt.filenames_cross{k}); 
            metadata.crossover{end+1} = nameCO; % add the filenames of crossover profiles to metadata 
        else
            clear geoinfo_co_idx geoinfo_idx
        end

        if exist('geoinfo_co_idx', 'var')
            %figure(3)
            %plot(P(:,1),P(:,2),'ko')
            %hold on
            %plot(P_co(:,1),P_co(:,2),'*g')
            %hold on
            %plot(P(geoinfo_idx,1),P(geoinfo_idx,2),'*r')
            %figure(2)
            if exist('geoinfo_co_idx', 'var')
                if isfield(geoinfo_co, 'layers')
                    geoinfo_co_layers = geoinfo_co.layers(:,geoinfo_co_idx);
                    dt_co=geoinfo_co.twt(2)-geoinfo_co.twt(1); % time step (for traces)

                    geoinfo_co.time_pick_abs=geoinfo_co.twt_sur(geoinfo_co_idx)-geoinfo_co.twt(1);
                    geoinfo_co_layers_ind=geoinfo_co_layers-(geoinfo_co.time_pick_abs/dt_co); % gives 430 - 215 (surface pick)

                    %geoinfo.time_range(geoinfo3layer1_ind)-geoinfo3.twt_sur(1);
                    geoinfo.time_pick_abs=geoinfo.twt_sur(geoinfo_idx)-geoinfo.twt(1); 
                    dt = geoinfo.twt(2) - geoinfo.twt(1);
                    geoinfo_layers_ind = NaN(opt.nol,1);
                    ncp = min(opt.nol, length(geoinfo_co_layers_ind)); % number of extracted cross points
                    geoinfo_layers_ind(1:ncp) = (geoinfo.time_pick_abs/dt)+geoinfo_co_layers_ind(1:ncp);                   
                end
            end
            if any(cp_layers, 'all')
                cp_idx = [cp_idx, geoinfo_idx];
                cp_layers = [cp_layers, geoinfo_layers_ind];
            elseif exist('geoinfo_layers_ind', 'var')
                cp_idx = geoinfo_idx;
                cp_layers = geoinfo_layers_ind;
            end
        end
    end
end

