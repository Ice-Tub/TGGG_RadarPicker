function [geoinfo, tp] = figure_tune(geoinfo,tp,opt)
%FIGURE_TUNE displays the radargram for surface and bottom picking.
%   Detailed explanation goes here

% Normalize data for plot
if strcmpi(opt.input_type, 'MCoRDS')
    norm_geo = mag2db(geoinfo.data);
else
    norm_geo = geoinfo.data;
end

norm_geo = norm_geo - min(norm_geo,[],'all'); % Shift data too positvie values only.    
norm_geo = norm_geo/max(norm_geo,[],'all'); % Normalize to range [0 1].
slider_step = [1/1000, 1/100];

% Create background plot.
fig1 = figure();
imagesc(tp.clms, tp.rows, norm_geo)
colormap(opt.cmp)
%colorbar
xlabel('Trace')
ylabel('Range bin')
yyaxis right
ylim(geoinfo.twt([1 end])./2*300/sqrt(3.17))
ylabel('Approximate depth (m)')
axis ij
yyaxis left
caxis([0.1 0.9])
hold on

% Obtain and show surface pick (depending on data type).
geoinfo = pick_surface(geoinfo,tp,opt);
plot(tp.clms,geoinfo.ind_sur,'Linewidth',2,'Color', [0 0.4470 0.7410]);

% update plots with bottom picks depending on input type
if opt.exist_bottom
    if opt.manual_bottom_pick
        % Position
        a = gca;
        apos=get(a,'position');
        set(a,'position',[apos(1) apos(2)+0.1 apos(3) apos(4)-0.1]);
        bpos=[apos(1) apos(2)-0.05 apos(3)/3 0.05];
        cpos=[apos(3)/3+0.15 apos(2)-0.09 0.12 0.05];
        dpos=[apos(3)/3+0.28 apos(2)-0.09 0.12 0.05];
        epos=[apos(3)/3+0.41 apos(2)-0.09 0.12 0.05];
        f0pos=[apos(3)/3+0.54 apos(2)-0.03 0.12 0.05];
        f1pos=[apos(3)/3+0.54 apos(2)-0.09 0.12 0.05];

        cr_half = opt.len_color_range/2;
        cmin = round(min(norm_geo,[],'all')+cr_half,2); % Added 2 for GPR here.
        cmax = round(max(norm_geo,[],'all')-cr_half,2);
        cini = (cmin+cmax)/2;
        set(a,'CLim',[cini-cr_half cini+cr_half]); % Initial color range

        clear data_scaled

        % Button settings
        ui_b = uicontrol('Parent',fig1,'Style','slider','Units','normalized','Position',bpos,...
                      'value',cini,'min',cmin,'max',cmax,'SliderStep',slider_step,'callback', @color_callback); % Color slider. Atm it uses fixed max and min values, instead they could be adopted to the file values.
        bgcolor = fig1.Color;
        uicontrol('Parent',fig1,'Style','text','Units','normalized','Position',[bpos(1)-0.05,bpos(2),0.05,bpos(4)],...
                                'String',num2str(cmin),'BackgroundColor',bgcolor);
        uicontrol('Parent',fig1,'Style','text','Units','normalized','Position',[bpos(1)+bpos(3)-0.05,bpos(2),0.05,bpos(4)],...
                        'String',num2str(cmax),'BackgroundColor',bgcolor);
        uicontrol('Parent',fig1,'Style','text','Units','normalized','Position',[bpos(1)+bpos(3)/2-0.15,bpos(2)-0.05,0.3,0.05],...
                        'String',append('Color range (value ',char(177),' ',int2str(cr_half),')'),'BackgroundColor',bgcolor);

        leftright = 1; % Go to left or right. lr = 1 -> right, lr = -1 -> left.
        ui_c = uicontrol('Parent',fig1,'Style','togglebutton', 'String', 'Go left','Units','normalized','Position',cpos,...
                      'value',leftright,'min',1,'max',-1,'callback', @left_callback); % Select to go left or right.

        editing_mode = 0;
        ui_d = uicontrol('Parent',fig1,'Style','togglebutton', 'String', 'Edit mode','Units','normalized','Position',dpos,...
                      'value',editing_mode,'min',0,'max',1,'callback', @edit_callback); % Select to go left or right.

        ui_e = uicontrol('Parent',fig1,'Style','pushbutton', 'String', 'Undo pick','Units','normalized','Position',epos,...
                      'callback', @undo_callback); % Finish selection

        ui_f0 = uicontrol('Parent',fig1,'Style','pushbutton', 'String', 'Save picks','Units','normalized','Position',f0pos,...
                      'Callback',@save_callback, 'UserData', 1); % Finish selection
                  
        ui_f = uicontrol('Parent',fig1,'Style','pushbutton', 'String', 'Bottom pick done','Units','normalized','Position',f1pos,...
                      'Callback',@end_callback, 'UserData', 1); % Finish selection

        
        first_iteration = true;

        while get(ui_f, 'UserData')
            if first_iteration
                botplot = plot(tp.clms,geoinfo.ind_bot,'-','Linewidth',2, 'Color', [0.8500    0.3250    0.0980]);
                disp('Move and zoom if needed. Press enter to start picking.')
                pan on;
                pause(); % you can zoom with your mouse and when your image is okay, you press any key
                pan off; % to escape the zoom mode
                if ~get(ui_f, 'UserData')
                    break
                end
                disp('Pick the first point. Only the last click is saved, confirm pick with enter.')
                first_iteration = false;
            else
               disp('Pick next point. To move or zoom, press enter.')
            end

            [x,y,type]=ginput(); % gathers points until return

            if ~get(ui_f, 'UserData')
                break
            end
            
            if length(x) == 2 && sum(type) == 2
                type_in = 10;
                [x_in, y_in, x_in2, y_in2] = deal(round(x(1)), round(y(1)), round(x(2)), round(y(2)));
            elseif ~isempty(x)
                [x_in,y_in,type_in] = deal(round(x(end)),round(y(end)),type(end));
            else
                type_in = [];
            end
            bottom_pick = geoinfo.ind_bot;
            if type_in == 1 % Left click, create picks. 
                %picks{cl}(end+1,:) = [x_in, y_in]; % Add new picks to pick-cell

                isnewlayer = all(isnan(bottom_pick), 'all'); % Check if layer is empty (True/False).

                bottom_pick = propagate_bottom(bottom_pick,geoinfo,tp,opt,x_in,y_in,leftright,editing_mode);
                if isnewlayer
                    bottom_pick = propagate_bottom(bottom_pick,geoinfo,tp,opt,x_in,y_in,-leftright,0);
                end
            elseif type_in==3 % Right click, delete picks.

                if editing_mode
                    del_min = max(1, x_in-opt.editing_window);
                    del_max = min(length(bottom_pick), x_in+opt.editing_window);
                else
                    del_min = 1;
                    del_max = length(bottom_pick);
                end
                if leftright==1
                    bottom_pick(x_in+1:del_max) = NaN;
                    quality(x_in+1:del_max) = NaN;
                else
                    bottom_pick(del_min:x_in-1) = NaN;
                    quality(del_min:x_in-1) = NaN;
                end
            elseif type_in == 10
                x_range = round(x(1)):round(x(2));
                rangle_length = length(x_range);
                bottom_pick(x_range) =  round(linspace(y(1), y(2), rangle_length));
                if ~editing_mode
                    if leftright == 1
                        bottom_pick = propagate_bottom(bottom_pick,geoinfo,tp,opt,x_in2,y_in2,leftright,editing_mode);
                    else
                        bottom_pick = propagate_bottom(bottom_pick,geoinfo,tp,opt,x_in,y_in,leftright,editing_mode);
                    end
                end
            elseif isempty(type_in)
                disp('Move and zoom. To continue picking, press enter.')
                pan on;
                pause() % you can zoom with your mouse and when your image is okay, you press any key
                pan off; % to escape the zoom mode
                if ~get(ui_f, 'UserData')
                    break
                end
            else
                disp('Input type unknown. Only pick with left and right mouse buttons.')
            end

            if ~isempty(type_in)
                bot_old = geoinfo.ind_bot;
                geoinfo.ind_bot = bottom_pick;
            end
            % Plot updated layer
            try
                delete(botplot);
            end
            botplot = plot(tp.clms,geoinfo.ind_bot,'-','Linewidth',2, 'Color', [0.8500    0.3250    0.0980]);
        end
           
    else



        % Include and update surface and bottom picks
    %     updatePlotMinPeaks = 1;
    %     updatePlotMax = 1;
        updatePlot = 1; % Active untill user has finished picking the bottom
        manual_MinBFBP = 0;
        manual_MaxBFBP = 0;
        %MinBinBottom = ones(1,geoinfo.num_trace) * tp.MinBinForBottomPick;
        %MaxBinBottom = ones(1,geoinfo.num_trace) * min(tp.MaxBinForBottomPick, length(tp.rows));
        dt=geoinfo.twt(2)-geoinfo.twt(1);
        t1=geoinfo.twt(1);

        while updatePlot 

            if manual_MaxBFBP
                disp('Pick a variable MaxBinForBottomPick.')
                [x,y,~]=ginput(); %gathers points until return

                if ~isempty(x)
                    x = round(x);
                    y = y(x>=tp.clms(1) & x<=tp.clms(end));
                    y = y(x>=tp.clms(1) & x<=tp.clms(end));
                    x = [tp.clms(1); x; tp.clms(end)];
                    y = [y(1); y; y(end)];
                    y_ind = round((y - t1)/dt);
                    MaxBinBottom = interp1q(x,y_ind,tp.clms');
                    MaxBinBottom = round(MaxBinBottom');
                end
            end

            if manual_MinBFBP
                disp('Pick a variable MinBinForBottomPick.')
                [x,y,~]=ginput(); %gathers points until return

                if ~isempty(x)
                    x = round(x);
                    y = y(x>=tp.clms(1) & x<=tp.clms(end));
                    y = y(x>=tp.clms(1) & x<=tp.clms(end));
                    x = [tp.clms(1); x; tp.clms(end)];
                    y = [y(1); y; y(end)];
                    y_ind = round((y - t1)/dt);
                    MinBinBottom = interp1q(x,y_ind,tp.clms');
                    MinBinBottom = round(MinBinBottom');
                end
            end

            if opt.update_bottom
                %pick main reflectors (the bottom pick is very important for background
                %noise associated with mexh wavelet (morl can handle more noise but give less accurate results)
                geoinfo = pick_bottom(geoinfo,tp,opt,MinBinBottom,MaxBinBottom);
            end

            % Delete existing surface and bottom pick
            if exist('botplot','var')
                delete(minplot);
                delete(botplot);
                delete(maxplot);
            end

            % MinBinBottomPlot=(MinBinBottom*dt)+t1;
            % MaxBinBottomPlot=(MaxBinBottom*dt)+t1;
            % plot new surface and bottom pick
            minplot = plot(tp.clms,MinBinBottom, 'k--');
            hold on
            botplot = plot(tp.clms,geoinfo.ind_bot,'-','Linewidth',2, 'Color', [0.8500    0.3250    0.0980]);
            maxplot = plot(tp.clms,MaxBinBottom, 'k--');

            % define minBinForBottom manually and number of bottom peaks
            % manually
            disp('Show surface and bottom picks.')

            prompt = {'Number of bottom peaks:','Pick MinBinForBottomPick manually (1=yes, 0=no):', 'Pick MaxBinForBottomPick manually (1=yes, 0=no):'};
            dlgtitle = 'Update minimum and/or maximum bottom pick?';
            dims = [1 35];
            definput = {int2str(tp.num_bottom_peaks),'0', '0'};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            updatePlot = ~isempty(answer);
            if updatePlot
                tp.num_bottom_peaks = str2double(answer{1});
                manual_MinBFBP = str2double(answer{2});
                manual_MaxBFBP = str2double(answer{3});
                disp('Processing new bottom pick...')
            end
        end
    end
end

geoinfo.tp = tp; % Include updated tuning parameters in geoinfo.

%% Callback functions
       
    function color_callback(~, ~)
        set(gca,'CLim',[get(gcbo,'value')-cr_half, get(gcbo,'value')+cr_half])
    end


    function left_callback(~, ~)
        leftright = get(gcbo,'value');
    end


    function edit_callback(~, ~)
        editing_mode = get(gcbo,'value');
    end


    function undo_callback(~, ~)
        geoinfo.ind_bot = bot_old;
        %try
            %set(botplot,{'YData'},mat2cell([bot_old; bot_old(cl,:)],[ones(9,1)]));
            % ToDo: There is probably some bug caused by this-------------^ 9.
        %end
    end


    function save_callback(~, ~)
        save_bottom(geoinfo,tp,opt)
        disp('Bottom pick saved');
    end


    function end_callback(~, ~)
        set(ui_f, 'UserData', 0);
        save_bottom(geoinfo,tp,opt)
        disp('Finished bottom pick');
    end
end
