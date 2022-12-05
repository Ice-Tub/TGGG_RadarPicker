function [geoinfo] = load_old_layers(geoinfo,opt)
%LOAD_OLD_LAYERS Summary of this function goes here
%   Detailed explanation goes here
    geoinfo_old = load(opt.filename_geoinfo);
    geoinfo.num_layer = geoinfo_old.num_layer;
    if isfield(geoinfo_old, 'ind_bot')
        geoinfo.ind_bot = geoinfo_old.ind_bot;
        geoinfo.twt_bot = geoinfo_old.twt_bot;
    end
    clms_old = geoinfo_old.tp.clms;
    clms_new = geoinfo.tp.clms;
    clms_old_min = max(1,clms_new(1)-clms_old(1)+1);
    clms_old_max = min(length(clms_old),clms_new(end)-clms_old(1)+1);
    clms_new_min = max(1,clms_old(1)-clms_new(1)+1);
    clms_new_max = min(length(clms_new),clms_old(end)-clms_new(1)+1);

    geoinfo.layers = NaN(opt.nol,geoinfo.num_trace);
    %geoinfo.layers_relto_surface = NaN(opt.nol,geoinfo.num_trace);
    %geoinfo.layers_topo = NaN(opt.nol,geoinfo.num_trace);
    %geoinfo.layers_topo_depth = NaN(opt.nol,geoinfo.num_trace);
    geoinfo.qualities = NaN(opt.nol,geoinfo.num_trace);


    if isfield(geoinfo_old,'layers')
        nool = size(geoinfo_old.layers,1); % number of old layers
        geoinfo.layers(1:nool, clms_new_min:clms_new_max) = geoinfo_old.layers(:, clms_old_min:clms_old_max);
        %if ~strcmpi(opt.input_type, 'awi_flight')
           % geoinfo.layers_relto_surface(1:nool, clms_new_min:clms_new_max) = geoinfo_old.layers_relto_surface(:, clms_old_min:clms_old_max);
            %geoinfo.layers_topo(1:nool, clms_new_min:clms_new_max) = geoinfo_old.layers_topo(:, clms_old_min:clms_old_max);
            %geoinfo.layers_topo_depth(1:nool, clms_new_min:clms_new_max) = geoinfo_old.layers_topo_depth(:, clms_old_min:clms_old_max);
        %end
        geoinfo.qualities(1:nool, clms_new_min:clms_new_max) = geoinfo_old.qualities(:, clms_old_min:clms_old_max);
    end
end

