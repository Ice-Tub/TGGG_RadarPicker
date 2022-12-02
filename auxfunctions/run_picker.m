function [geoinfo] = run_picker(opt, tp)
% RUN_PICKER executes the picking routine.
    % This function calls the 

%%
    opt.nol = 18; % Number of layers. This options sets the nol that can be
    % be picked. Not include in 'picker.m', because changing it requires
    % GUI adaptation and might cause loss of data.
    
%% Preprocessing
    disp('Hello!') % Put some initial information here.
    
    opt = input_interpreter(opt);
    
    [geoinfo,tp] = initialize_geoinfo(tp,opt);
    metadata = initialize_metadata(geoinfo, opt);
    
    if isfile(opt.filename_geoinfo) && opt.keep_old_picks
        geoinfo = load_old_layers(geoinfo,opt);
    end
    
    if opt.update_bottom
        [geoinfo, tp] = figure_tune(geoinfo,tp,opt);
        
        opt.update_seeds = 1;
    end
    
    % Compute seed points for half-automated picking
    
    if opt.use_seedpoints && opt.update_seeds
        [geoinfo, opt] = compute_seeds(geoinfo,tp,opt);
    end
        

    % Activate to save geoinfo after preprocessing:
    %save(opt.filename_geoinfo, '-struct', 'geoinfo')
%% Layer picking
    [geoinfo, metadata] = figure_pick(geoinfo, metadata, tp, opt);

    save_picks(geoinfo,metadata,tp,opt) % Saving the geoinfo with picks
    disp('Picking finished. Your picks have been saved.')
end






