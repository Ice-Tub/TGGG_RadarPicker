function [geoinfo,tp] = initialize_geoinfo(tp,opt)
%INITIALIZE_GEOINFO loads or creates geoinfo.
%   Detailed explanation goes here

    if opt.create_new_geoinfo || ~isfile(opt.filename_geoinfo)
        geoinfo = readdata(opt.filename_input_data,opt.input_type,tp.rows,tp.clms);
        if ischar(tp.clms)
            if strcmp(tp.clms, 'all_clms')
                tp.clms = 1:size(geoinfo.data,2);
            end
        end
        opt.update_bottom = 1;
    else
        geoinfo = load(opt.filename_geoinfo);

        layers               = NaN(opt.nol, geoinfo.num_trace);
        qualities            = NaN(opt.nol, geoinfo.num_trace);

        if isfield(geoinfo,'layers')
            nool = size(geoinfo.layers,1); % number of old layers
            noel = min(opt.nol, nool); % number of exctracted layers

            layers(1:noel,:) = geoinfo.layers(1:noel,:);
            qualities(1:noel,:) = geoinfo.qualities(1:noel,:);
        end

        geoinfo.layers = layers;
        geoinfo.qualities = qualities;   

        geoinfo.peakim(geoinfo.peakim<tp.seedthresh) = 0; % Only needed for old data files
        tp.rows = geoinfo.tp.rows;
        tp.clms = geoinfo.tp.clms;
        tp.num_bottom_peaks = geoinfo.tp.num_bottom_peaks;
    end

    if ~isfield(geoinfo,'version')
        geoinfo = update_geoinfo(geoinfo);
    end
    
    % ToDo: Reorganize very specific options such as delete_stripes
    if opt.delete_stripes
        geoinfo.data_org = geoinfo.data;
        data_mean = mean(geoinfo.data_org,2);
        geoinfo.data = geoinfo.data_org-data_mean;
    end
    
    
   
    
end

