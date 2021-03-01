function run_picker(opt, tp)
% RUN_PICKER executes the picking routine.
    % This function calls the 

%%
    opt.nol = 10; % Number of layers. This options sets the nol that can be
    % be picked. Not include in 'picker.m', because changing it requires
    % GUI adaptation and might cause loss of data.
    
%% Preprocessing
    disp('Hello!') % Put some initial information here.
    
    opt = file_interpreter(opt); % Interpret input settings for filenames.
    
    [geoinfo,tp] = initialize_geoinfo(tp,opt);
    
    [geoinfo, tp] = figure_tune(geoinfo,tp,opt);
    
    if ~isfield(opt,'update_seeds')
        opt.update_seeds = 0;
    end

    if opt.update_bottom || opt.update_seeds
        [geoinfo, opt] = compute_seeds(geoinfo,tp,opt);
        
        if isfile(opt.filename_geoinfo) && opt.keep_old_picks
            [geoinfo] = load_old_layers(geoinfo,opt);
        end
    end
    
    % Activate to save geoinfo after preprocessing:
    %save(opt.filename_geoinfo, '-struct', 'geoinfo')
%% Layer picking
    figure_pick(geoinfo, tp, opt);

end






