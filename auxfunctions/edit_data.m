function edit_data(m_option, data_folder, mf_file, mfl, mt_file, mtl)
%%
% ToDo: Include option 'append'
%%

if ~contains(mf_file, '.mat')
    mf_file = append(mf_file, '.mat');
end
if ~contains(mt_file, '.mat')
    mt_file = append(mt_file, '.mat');
end

    mf_filepath = append(pwd, '\', data_folder, '\', mf_file);
    mt_filepath = append(pwd, '\', data_folder, '\', mt_file);
    
mf_geoinfo = load(mf_filepath);
mt_geoinfo = load(mt_filepath);

%%
if isequal(m_option, 'overwrite')
    edit_note = append('Overwriting line ', num2str(mtl), ' of ', mt_file, ' with line ', num2str(mfl), ' of ', mf_file,'.');
    disp(edit_note);
    mt_geoinfo.layers(mtl, :) = mf_geoinfo.layers(mfl, :);
    mt_geoinfo.layers_relto_surface(mtl, :) = mf_geoinfo.layers_relto_surface(mfl, :);
    mt_geoinfo.layers_topo(mtl, :) = mf_geoinfo.layers_topo(mfl, :);
    mt_geoinfo.layers_topo_depth(mtl, :) = mf_geoinfo.layers_topo_depth(mfl, :);
    mt_geoinfo.qualities(mtl, :) = mf_geoinfo.qualities(mfl, :);
elseif isequal(m_option, 'swap')
    if isequal(mf_file, mt_file)
        edit_note = append('Swapping line ', num2str(mtl), ' and ', num2str(mfl), ' of ', mt_file,'.');
        disp(edit_note)
        [mt_geoinfo.layers(mtl, :), mt_geoinfo.layers(mfl, :)] = deal(mf_geoinfo.layers(mfl, :), mf_geoinfo.layers(mtl, :));
        [mt_geoinfo.layers_relto_surface(mtl, :), mt_geoinfo.layers_relto_surface(mfl, :)] = deal(mf_geoinfo.layers_relto_surface(mfl, :), mf_geoinfo.layers_relto_surface(mtl, :));
        [mt_geoinfo.layers_topo(mtl, :), mt_geoinfo.layers_topo(mfl, :)] = deal(mf_geoinfo.layers_topo(mfl, :), mf_geoinfo.layers_topo(mtl, :));
        [mt_geoinfo.layers_topo_depth(mtl, :), mt_geoinfo.layers_topo_depth(mfl, :)] = deal(mf_geoinfo.layers_topo_depth(mfl, :), mf_geoinfo.layers_topo_depth(mtl, :));
        [mt_geoinfo.qualities(mtl, :), mt_geoinfo.qualities(mfl, :)] = deal(mf_geoinfo.qualities(mfl, :), mf_geoinfo.qualities(mtl, :));
    else
        disp("The 'swap'-option only works, if move_from_file and move_to_file are equal.")
    end
elseif isequal(m_option, 'view')
    disp(append('You can now view file ', mt_file,'.'))
else
    option_alert = append("move_option '", m_option, "' is not known.");
    disp(option_alert)
end

%%
db_echogram = mag2db(mt_geoinfo.echogram);
f = figure(2); % of flat data with seed points
imagesc(db_echogram);
colormap(jet)
hold on
set(gcf,'doublebuffer','on');
a = gca;
cmin = round(min(db_echogram,[],'all')+50);
cmax = round(max(db_echogram,[],'all')-50);
%cini = min(cmax,-150);
set(a,'CLim',[cmin, cmax]);
clear db_echogram

apos=get(a,'position');
set(a,'position',[apos(1) apos(2)+0.1 apos(3) apos(4)-0.1]);
bpos=[0.35 apos(2)-0.05 0.145 0.05];
cpos=[0.505 apos(2)-0.05 0.14 0.05];

cl = 1; % Set number of current layer    

ui_c = uicontrol('Parent',f,'Style','popupmenu', 'String', {'Layer 1','Layer 2','Layer 3','Layer 4','Layer 5','Layer 6','Layer 7','Layer 8','Layer 9','Layer 10'},'Units','normalized','Position',bpos,...
                  'value',cl,'callback', @layer_callback); % Choose layer.

ui_f1 = uicontrol('Parent',f,'Style','pushbutton', 'String', 'Save changes','Units','normalized','Position',cpos,...
              'callback',@save_callback); % Finish selection

layerplot = plot(1:length(mt_geoinfo.layers),mt_geoinfo.layers,'k-x',1:length(mt_geoinfo.layers(cl,:)),mt_geoinfo.layers(cl,:),'b-x');
disp('Press "Save changes" to write changes to file.')

    function layer_callback(~, ~)
        cl = get(gcbo,'value');
        try
            set(layerplot(end),'YData',mt_geoinfo.layers(cl,:));
        end
    end


    function save_callback(~, ~)
    save(mt_filepath, '-struct', 'mt_geoinfo');
    disp('Changes were saved.')
    end

    
end