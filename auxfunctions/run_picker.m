function run_picker(opt, tp)
% RUN_PICKER executes the picking routine.
    
%%
    nol = 10; % number of layers
    
    if ~contains(opt.input_file, '.mat')
        opt.input_file = append(opt.input_file, '.mat');
    end
    if ~contains(opt.output_suffix, '.mat')
        opt.output_suffix = append(opt.output_suffix, '.mat');
    end

    opt.filename_input_data = append(pwd, opt.input_folder, opt.input_file); % Inputfile not needed if geoinfofile already exists.
    opt.filename_geoinfo = append(pwd, opt.output_folder, opt.output_prefix, opt.output_suffix);
    if opt.load_crossover
        filenames_cross = {};
        if strcmp(opt.cross_section,'all')
            cross_struct = dir(append(pwd, opt.output_folder,'\*.mat'));
            n_cross = length(cross_struct);
            for k = 1:n_cross
                filename_cross = append(cross_struct(k).folder, '\', cross_struct(k).name);
                filenames_cross = [filenames_cross; filename_cross];
            end
        else
            if ischar(opt.cross_section)
                opt.cross_section = {opt.cross_section};
            end
            n_cross = numel(opt.cross_section);
            for k = 1:n_cross
                filename_cross = append(pwd,opt.output_folder,opt.output_prefix,opt.cross_section{k},'.mat');
                filenames_cross = [filenames_cross; filename_cross];
            end
        end
        opt.filenames_cross = setdiff(filenames_cross, {opt.filename_geoinfo});
        n_cross = length(opt.filenames_cross);
    end
    [geoinfo, tp] = figure_tune(tp,opt);
    %%
    ind = find(geoinfo.peakim);
    [sy,sx]=ind2sub(size(geoinfo.peakim), ind);
    nx = size(geoinfo.data,2);

    dt=geoinfo.twt(2)-geoinfo.twt(1);%time step (for traces)
    time_surface = geoinfo.traveltime_surface-geoinfo.twt(1);
    surface_ind = time_surface/dt;

    dz = dt/2*1.68e8;
    binshift = round((tp.RefHeight - geoinfo.elevation_sur)/dz);%this is essentially the surface reflector
    %%
    if strcmpi(opt.input_type, 'MCoRDS')
        db_data = mag2db(geoinfo.data);
    elseif strcmpi(opt.input_type, 'GPR_LF')
        db_data = geoinfo.data;
    end
    f = figure(2); % of flat data with seed points
    imagesc(db_data);
    colormap(opt.cmp)
    hold on
    plot(sx,sy,'r*', 'MarkerSize', 2) % plot seedpoints
    set(gcf,'doublebuffer','on');
    a = gca;
    cr_half = opt.len_color_range/2;

    apos=get(a,'position');
    set(a,'position',[apos(1) apos(2)+0.1 apos(3) apos(4)-0.1]);
    bpos=[apos(1) apos(2)-0.05 apos(3)/3 0.05];
    cpos=[apos(3)/3+0.15 apos(2)-0.03 0.12 0.05];
    d1pos=[apos(3)/3+0.28 apos(2)-0.03 0.12 0.05];
    d2pos=[apos(3)/3+0.28 apos(2)-0.09 0.12 0.05];
    e1pos=[apos(3)/3+0.41 apos(2)-0.03 0.12 0.05];
    f1pos=[apos(3)/3+0.54 apos(2)-0.03 0.12 0.05];
    f2pos=[apos(3)/3+0.54 apos(2)-0.09 0.12 0.05];



    cmin = round(min(db_data,[],'all')+cr_half,2); % Added 2 for GPR here.
    cmax = round(max(db_data,[],'all')-cr_half,2);
    cini = (cmin+cmax)/2;
    set(a,'CLim',[cini-cr_half cini+cr_half]); % Initial color range

    clear db_echogram
    % Create color slider
    ui_b = uicontrol('Parent',f,'Style','slider','Units','normalized','Position',bpos,...
                  'value',cini,'min',cmin,'max',cmax,'SliderStep',[cr_half/10, cr_half],'callback', @color_callback); % Color slider. Atm it uses fixed max and min values, instead they could be adopted to the file values.
    bgcolor = f.Color;
    uicontrol('Parent',f,'Style','text','Units','normalized','Position',[bpos(1)-0.05,bpos(2),0.05,bpos(4)],...
                            'String',num2str(cmin),'BackgroundColor',bgcolor);
    uicontrol('Parent',f,'Style','text','Units','normalized','Position',[bpos(1)+bpos(3)-0.05,bpos(2),0.05,bpos(4)],...
                    'String',num2str(cmax),'BackgroundColor',bgcolor);
    uicontrol('Parent',f,'Style','text','Units','normalized','Position',[bpos(1)+bpos(3)/2-0.15,bpos(2)-0.05,0.3,0.05],...
                    'String',append('Color range (value ',char(177),' ',int2str(cr_half),')'),'BackgroundColor',bgcolor);

    cl = 1; % Set number of current layers    
    ui_c = uicontrol('Parent',f,'Style','popupmenu', 'String', {'Layer 1','Layer 2','Layer 3','Layer 4','Layer 5','Layer 6','Layer 7','Layer 8','Layer 9','Layer 10'},'Units','normalized','Position',cpos,...
                  'value',cl,'callback', @layer_callback); % Choose layer.

    leftright = 1; % Go to left or right. lr = 1 -> right, lr = -1 -> left.
    ui_d1 = uicontrol('Parent',f,'Style','togglebutton', 'String', 'Go left','Units','normalized','Position',d1pos,...
                  'value',leftright,'min',1,'max',-1,'callback', @left_callback); % Select to go left or right.
              
    editing_mode = 0;
    ui_d2 = uicontrol('Parent',f,'Style','togglebutton', 'String', 'Edit mode','Units','normalized','Position',d2pos,...
                  'value',editing_mode,'min',0,'max',1,'callback', @edit_callback); % Select to go left or right.

    ui_e1 = uicontrol('Parent',f,'Style','pushbutton', 'String', 'Undo pick','Units','normalized','Position',e1pos,...
                  'callback', @undo_callback); % Finish selection

    ui_f1 = uicontrol('Parent',f,'Style','pushbutton', 'String', 'Save picks','Units','normalized','Position',f1pos,...
                  'callback',@save_callback); % Finish selection
    
    ui_f2 = uicontrol('Parent',f,'Style','pushbutton', 'String', 'End picking','Units','normalized','Position',f2pos,...
                  'Callback',@end_callback, 'UserData', 1); % Finish selection


    %% Figure out cross-overs (load geoinfo3 in this case)
    % need to load geoinfo3 manually

    cross_point_idx = NaN;
    cross_point_layers = NaN(nol,1);
    if opt.load_crossover
        for k = 1:n_cross
            geoinfo_co = load(filenames_cross{k}); % Loading the cross-over file
            if ~isfield(geoinfo_co,'psX') % Check if polar stereographic coordinates not exist in file
                [geoinfo_co.psX,geoinfo_co.psY] = ll2ps(geoinfo_co.latitude,geoinfo_co.longitude); %convert to polar stereographic
            end

            P = [geoinfo.psX; geoinfo.psY]';
            P_co= [geoinfo_co.psX; geoinfo_co.psY]';
            [points_dist,dist] = dsearchn(P,P_co);

            [val_dist, pos_dist] = min(dist);

            distthresh  = 10;  % Minimal allowed distance between cross- or neighbour-points.
            if val_dist < 10
                geoinfo_co_idx = pos_dist;
                geoinfo_idx = points_dist(pos_dist);
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
                        dt=geoinfo_co.twt(2)-geoinfo_co.twt(1);%time step (for traces)

                        geoinfo_co.time_pick_abs=geoinfo_co.traveltime_surface(geoinfo_co_idx)-geoinfo_co.twt(1);
                        geoinfo_co_layers_ind=geoinfo_co_layers-(geoinfo_co.time_pick_abs/dt); % gives 430 - 215 (surface pick)

                        %geoinfo.time_range(geoinfo3layer1_ind)-geoinfo3.traveltime_surface(1);
                        geoinfo.time_pick_abs=geoinfo.traveltime_surface(geoinfo_idx)-geoinfo_co.twt(1);
                        geoinfo_layers_ind = NaN(nol,1);
                        ncp = min(nol, length(geoinfo_co_layers_ind)); % number of exctracted cross points
                        geoinfo_layers_ind(1:ncp) = (geoinfo.time_pick_abs/dt)+geoinfo_co_layers_ind(1:ncp);
                    end
                end
                if any(cross_point_layers)
                    cross_point_idx = [cross_point_idx, geoinfo_idx];
                    cross_point_layers = [cross_point_layers, geoinfo_layers_ind];
                elseif exist('geoinfo_layers_ind', 'var')
                    cross_point_idx = geoinfo_idx;
                    cross_point_layers = geoinfo_layers_ind;
                end
                clear geoinfo_co_layers_ind geoinfo_layers_ind geoinfo_co_idx geoinfo_idx
            end
        end
    end

    co_plot = plot(cross_point_idx,cross_point_layers,'k*', cross_point_idx, cross_point_layers(cl,:),'b*', 'MarkerSize', 16);% this plots the overlapping point in this graph

    %% Select starting point
    % Make NaN matrix for 10 (nol) possible layers
    if isfield(geoinfo,'layers')
        layers = geoinfo.layers;
        qualities = geoinfo.qualities;
    else
        layers = NaN(nol,nx);
        qualities = NaN(nol,nx);
    end

    picks = cell(nol, 1);

    iteration = 1;

    while get(ui_f2, 'UserData')
    if iteration == 1
        layerplot = plot(1:length(layers),layers,'k-x',1:length(layers(cl,:)),layers(cl,:),'b-x');
        disp('Move and zoom if needed. Press enter to start picking.')
        pan on;
        pause(); % you can zoom with your mouse and when your image is okay, you press any key
        pan off; % to escape the zoom mode
        if ~get(ui_f2, 'UserData')
            break
        end
        disp('Pick the first point. Only the last click is saved, confirm pick with enter.')
        iteration = iteration + 1;
    else
       disp('Pick next point. To move or zoom, press enter.')
    end

    [x,y,type]=ginput(); %gathers points until return

    if ~get(ui_f2, 'UserData')
        break
    end

    if ~isempty(x)
        [x_in,y_in,type_in] = deal(round(x(end)),round(y(end)),type(end));
    else
        [x_in,y_in,type_in] = deal(x,y,type);
    end
    layer = layers(cl,:);
    quality = qualities(cl,:);
    if type_in == 1
        picks{cl}(end+1,:) = [x_in, y_in]; % Add new picks to pick-cell

        isnewlayer = all(isnan(layer), 'all'); % Check if layer is empty (True/False).

        [layer,quality] = propagate_layer(layer,quality,geoinfo,tp,opt,x_in,y_in,leftright,editing_mode);
        if isnewlayer
            [layer,quality] = propagate_layer(layer,quality,geoinfo,tp,opt,x_in,y_in,-leftright,0);
        end
    elseif type_in==3
        if editing_mode
            del_min = max(1, x_in-opt.editing_window);
            del_max = min(length(layer), x_in+opt.editing_window);
        else
            del_min = 1;
            del_max = length(layer);
        end
        if leftright ==1
            layer(x_in+1:del_max) = NaN;
        else
            layer(del_min:x_in-1) = NaN;
        end
    elseif isempty(type_in)
        disp('Move and zoom. To continue picking, press enter.')
        pan on;
        pause() % you can zoom with your mouse and when your image is okay, you press any key
        pan off; % to escape the zoom mode
        if ~get(ui_f2, 'UserData')
            break
        end
    else
        disp('Input type unknown. Only pick with left and right mouse buttons.')
    end

    if ~isempty(type_in)
        layers_old = layers;
        layers(cl,:) = layer;
        qualities(cl,:) = quality;
        layers_relto_surface = layers - surface_ind;
        layers_topo = layers_relto_surface + binshift;
        layers_topo_depth = tp.RefHeight - layers_topo * dz;
    end
    % Plot updated layer
    try
        delete(layerplot);
    end
        layerplot = plot(1:length(layers),layers,'k-x',1:length(layers(cl,:)),layers(cl,:),'b-x');
    end
    disp('Picking finished. Picked layers are saved.')


    %% save layer
    layers_relto_surface = layers - surface_ind;
    layers_topo = layers_relto_surface + binshift;
    layers_topo_depth = tp.RefHeight - layers_topo * dz;
    
    if isfield(geoinfo,'data_org')
        geoinfo.data = geoinfo.data_org;
        geoinfo = rmfield(geoinfo,'data_org');
    end
    geoinfo.num_layer = sum(max(~isnan(layers),[],2));
    geoinfo.layers = layers;
    geoinfo.layers_relto_surface = layers_relto_surface;
    geoinfo.layers_topo = layers_topo;
    geoinfo.layers_topo_depth = layers_topo_depth;
    geoinfo.qualities = qualities;
    geoinfo.tp = tp;
    %geoinfo.layer1(geoinfoidx,2)=geoinfolayer1_ind; %still keep the overlapping point in the data
    save(opt.filename_geoinfo, '-struct', 'geoinfo')
    
    
    function color_callback(~, ~)
        set(gca,'CLim',[get(gcbo,'value')-cr_half, get(gcbo,'value')+cr_half])
    end


    function layer_callback(~, ~)
        cl = get(gcbo,'value');
        try
            set(layerplot(end),'YData',layers(cl,:));
        end
        try
            set(co_plot(end),'YData',cross_point_layers(cl,:));
        end
    end


    function left_callback(~, ~)
        leftright = get(gcbo,'value');
    end


    function edit_callback(~, ~)
        editing_mode = get(gcbo,'value');
    end


    function undo_callback(~, ~)
        layers = layers_old;
        try
            set(layerplot,{'YData'},mat2cell([layers_old; layers_old(cl,:)],[ones(9,1)]));
        end
    end    


    function save_callback(~, ~)
        if isfield(geoinfo,'data_org')
            geoinfo.data = geoinfo.data_org;
            geoinfo = rmfield(geoinfo,'data_org');
        end

        layers_relto_surface = layers - surface_ind;
        layers_topo = layers_relto_surface + binshift;
        layers_topo_depth = tp.RefHeight - layers_topo * dz;
        geoinfo.num_layer = sum(max(~isnan(layers),[],2));
        geoinfo.layers = layers;
        geoinfo.layers_relto_surface = layers_relto_surface;
        geoinfo.layers_topo = layers_topo;
        geoinfo.layers_topo_depth = layers_topo_depth;
        geoinfo.qualities = qualities;
        geoinfo.tp = tp;
        save(opt.filename_geoinfo, '-struct', 'geoinfo');
        disp('Picks are saved.');
        
        geoinfo.data_org = geoinfo.data;
        data_mean = mean(geoinfo.data_org,2);
        geoinfo.data = geoinfo.data_org-data_mean;
    end


    function end_callback(~, ~)
        set(ui_f2, 'UserData', 0);
    end

end






