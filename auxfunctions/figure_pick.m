function [geoinfo, metadata] = figure_pick(geoinfo, metadata, tp, opt)
%FIGURE_PICK Summary of this function goes here
%   Detailed explanation goes here

    %% Adapt to input type.
    
    if strcmpi(opt.input_type, 'MCoRDS')
        data_scaled = mag2db(geoinfo.data); % Rescale MCoRDS data to db.
    else
        data_scaled = geoinfo.data;
    end        
        slider_step = [1/100, 1/100];
        
     % if filter_frequencies activated, filter frequencies over 10 MHz
    if opt.filter_frequencies
        dt = geoinfo.twt(2)-geoinfo.twt(1);
        geoinfo.data_filtered = lowpass(geoinfo.data, 1*10^7*dt);
        data_scaled = geoinfo.data_filtered;
    end
    
    data_scaled = data_scaled - min(data_scaled,[],'all'); % Shift data too positvie values only.    
    data_scaled = data_scaled/max(data_scaled,[],'all'); % Normalize to range [0 1].
    
    %% Plot radar data
    
    fig2 = figure(); % of flat data with seed points
    
    imagesc(data_scaled);
    hold on
    botplot = plot(tp.clms,geoinfo.ind_bot,'-','Linewidth',2, 'Color', [0.8500    0.3250    0.0980]);
    
    colormap(opt.cmp)
    caxis([0.1,0.9])
    colorbar
    a = gca;
    
    % If seedpoints are used, they are plotted in the following
    if opt.use_seedpoints
        [sy,sx] = find(geoinfo.peakim); % Extract seed point locations
        plot(sx,sy,'r*', 'MarkerSize', 2) % plot seedpoints
        %set(gcf,'doublebuffer','on');
    end

    %% Create color slider and buttons
    % Position
    apos=get(a,'position');
    set(a,'position',[apos(1) apos(2)+0.1 apos(3) apos(4)-0.1]);
    bpos=[apos(1) apos(2)-0.05 apos(3)/3 0.05];
    cpos=[apos(3)/3+0.15 apos(2)-0.03 0.12 0.05];
    d1pos=[apos(3)/3+0.28 apos(2)-0.03 0.12 0.05];
    d2pos=[apos(3)/3+0.28 apos(2)-0.09 0.12 0.05];
    e1pos=[apos(3)/3+0.41 apos(2)-0.03 0.12 0.05];
    f1pos=[apos(3)/3+0.54 apos(2)-0.03 0.12 0.05];
    f2pos=[apos(3)/3+0.54 apos(2)-0.09 0.12 0.05];

    cr_half = opt.len_color_range/2;
        
    cmin = round(min(data_scaled,[],'all')+cr_half,2); % Added 2 for GPR here.
    cmax = round(max(data_scaled,[],'all')-cr_half,2);
    cini = (cmin+cmax)/2;
    set(a,'CLim',[cini-cr_half cini+cr_half]); % Initial color range

    clear data_scaled
    
    % Button settings
    ui_b = uicontrol('Parent',fig2,'Style','slider','Units','normalized','Position',bpos,...
                     'value',cini,'min',cmin,'max',cmax,'SliderStep',slider_step,'callback', @color_callback); % Color slider. Atm it uses fixed max and min values, instead they could be adopted to the file values.
    bgcolor = fig2.Color;
    uicontrol('Parent',fig2,'Style','text','Units','normalized','Position',[bpos(1)-0.05,bpos(2),0.05,bpos(4)],...
              'String',num2str(cmin),'BackgroundColor',bgcolor);
    uicontrol('Parent',fig2,'Style','text','Units','normalized','Position',[bpos(1)+bpos(3)-0.05,bpos(2),0.05,bpos(4)],...
                    'String',num2str(cmax),'BackgroundColor',bgcolor);
    uicontrol('Parent',fig2,'Style','text','Units','normalized','Position',[bpos(1)+bpos(3)/2-0.15,bpos(2)-0.05,0.3,0.05],...
                    'String',append('Color range (value ',char(177),' ',int2str(cr_half),')'),'BackgroundColor',bgcolor);

    cl = 1; % Set number of current layers    
    ui_c = uicontrol('Parent',fig2,'Style','popupmenu', 'String', {'Layer 1','Layer 2','Layer 3','Layer 4','Layer 5','Layer 6','Layer 7','Layer 8','Layer 9','Layer 10', 'Layer 11', 'Layer 12', 'Layer 13', 'Layer 14', 'Layer 15', 'Layer 16', 'Layer 17', 'Layer 18'},'Units','normalized','Position',cpos,...
                  'value',cl,'callback', @layer_callback); % Choose layer.

    leftright = 1; % Go to left or right. lr = 1 -> right, lr = -1 -> left.
    ui_d1 = uicontrol('Parent',fig2,'Style','togglebutton', 'String', 'Go left','Units','normalized','Position',d1pos,...
                  'value',leftright,'min',1,'max',-1,'callback', @left_callback); % Select to go left or right.
              
    editing_mode = 0;
    ui_d2 = uicontrol('Parent',fig2,'Style','togglebutton', 'String', 'Edit mode','Units','normalized','Position',d2pos,...
                  'value',editing_mode,'min',0,'max',1,'callback', @edit_callback); % Select to go left or right.

    ui_e1 = uicontrol('Parent',fig2,'Style','pushbutton', 'String', 'Undo pick','Units','normalized','Position',e1pos,...
                  'callback', @undo_callback); % Finish selection

    ui_f1 = uicontrol('Parent',fig2,'Style','pushbutton', 'String', 'Save picks','Units','normalized','Position',f1pos,...
                  'callback',@save_callback); % Finish selection
    
    ui_f2 = uicontrol('Parent',fig2,'Style','pushbutton', 'String', 'End picking','Units','normalized','Position',f2pos,...
                  'Callback',@end_callback, 'UserData', 1); % Finish selection

    %% Plot cross points.
    if opt.load_crossover
        [metadata, cp_idx,cp_layers] = load_crosspoints(geoinfo,metadata, opt);
        co_plot = plot(cp_idx,cp_layers,'k*', cp_idx, cp_layers(cl,:),'b*', 'MarkerSize', 16);% this plots the overlapping point in this graph
    end
    
    %% Receiving manual picks
    % Make NaN matrix for opt.nol possible layers
    if ~isfield(geoinfo,'layers')
        geoinfo.layers = NaN(opt.nol,geoinfo.num_trace);
        geoinfo.qualities = NaN(opt.nol,geoinfo.num_trace);
    end

    %picks = cell(opt.nol, 1);

    iteration = 1;

    while get(ui_f2, 'UserData')
        if iteration == 1
            layerplot = plot(1:length(geoinfo.layers),geoinfo.layers,'k-x',1:length(geoinfo.layers(cl,:)),geoinfo.layers(cl,:),'m-x');
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

        [x,y,type]=ginput(); % gathers points until return

        if ~get(ui_f2, 'UserData')
            break
        end

        if ~isempty(type)
            %disp(strcat('x=', string(x)))
            %disp(strcat('y=', string(y)))
            %disp(strcat('type=', string(type)))
            [x_in,y_in,type_in] = deal(round(x(end)),round(y(end)),type(end));
        else
            [x_in,y_in,type_in] = deal(x,y,type);
        end
        layer = geoinfo.layers(cl,:);
        quality = geoinfo.qualities(cl,:);
        if type_in == 1 % Left click, create picks. 
            %picks{cl}(end+1,:) = [x_in, y_in]; % Add new picks to pick-cell

            isnewlayer = all(isnan(layer), 'all'); % Check if layer is empty (True/False).

            [layer,quality] = propagate_layer(layer,quality,geoinfo,tp,opt,x_in,y_in,leftright,editing_mode);
            if isnewlayer
                [layer,quality] = propagate_layer(layer,quality,geoinfo,tp,opt,x_in,y_in,-leftright,0);
            end
        elseif type_in==3 % Right click, delete picks.
           
            if editing_mode
                del_min = max(1, x_in-opt.editing_window);
                del_max = min(length(layer), x_in+opt.editing_window);
            else
                del_min = 1;
                del_max = length(layer);
            end
            if leftright==1
                layer(x_in+1:del_max) = NaN;
                quality(x_in+1:del_max) = NaN;
            else
                layer(del_min:x_in-1) = NaN;
                quality(del_min:x_in-1) = NaN;
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
            layers_old = geoinfo.layers;
            qualities_old = geoinfo.qualities;
            geoinfo.layers(cl,:) = layer;
            geoinfo.qualities(cl,:) = quality;
        end
        % Plot updated layer
        try
            delete(layerplot);
        end
        layerplot = plot(1:length(geoinfo.layers),geoinfo.layers,'k-x',1:length(geoinfo.layers(cl,:)),geoinfo.layers(cl,:),'m-x');
    end
    
    %% Callback functions
       
    function color_callback(~, ~)
        set(gca,'CLim',[get(gcbo,'value')-cr_half, get(gcbo,'value')+cr_half])
    end


    function layer_callback(~, ~)
        cl = get(gcbo,'value');
        try
            set(layerplot(end),'YData',geoinfo.layers(cl,:));
        end
        try
            set(co_plot(end),'YData',cp_layers(cl,:));
        end
    end


    function left_callback(~, ~)
        leftright = get(gcbo,'value');
    end


    function edit_callback(~, ~)
        editing_mode = get(gcbo,'value');
    end


    function undo_callback(~, ~)
        geoinfo.layers = layers_old;
        geoinfo.qualities = qualities_old;
        try
            set(layerplot,{'YData'},mat2cell([layers_old; layers_old(cl,:)],[ones(9,1)]));
        end
    end    


    function save_callback(~, ~)
        save_picks(geoinfo,metadata,tp,opt)
        disp('Picks are saved.');
    end


    function end_callback(~, ~)
        set(ui_f2, 'UserData', 0);
    end

end

