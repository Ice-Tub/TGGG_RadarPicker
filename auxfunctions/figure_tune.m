function [geoinfo, tp] = figure_tune(tp,opt)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Building a while loop for tuneing the figure parameters.
%presettings_ok = 0;
%while ~presettings_ok
%
%    presettings_ok = 1;
%end

if opt.create_new_geoinfo
    geoinfo = readdata(opt.filename_input_data,opt.input_type,tp.rows,tp.clms);
    opt.update_bottom = 1;
elseif ~isfile(opt.filename_geoinfo)
    geoinfo = readdata(opt.filename_input_data,opt.input_type,tp.rows,tp.clms);
    opt.update_bottom = 1;
else
    geoinfo = load(opt.filename_geoinfo);
<<<<<<< Updated upstream
=======
    nt = geoinfo.num_trace;
    layers = NaN(nol,nt);
    qualities = NaN(nol,nt);
    layers_relto_surface = NaN(nol,nt);
    layers_topo = NaN(nol,nt);
    layers_topo_depth = NaN(nol,nt);
        
    if isfield(geoinfo,'layers')
        nool = size(geoinfo.layers,1); % number of old layers
        noel = min(nol, nool); % number of exctracted layers
    
        layers(1:noel,:) = geoinfo.layers(1:noel,:);
        qualities(1:noel,:) = geoinfo.qualities(1:noel,:);
        layers_relto_surface(1:noel,:) = geoinfo.layers_relto_surface(1:noel,:);
        layers_topo(1:noel,:) = geoinfo.layers_topo(1:noel,:);
        layers_topo_depth(1:noel,:) = geoinfo.layers_topo_depth(1:noel,:);
    end
    
    geoinfo.layers = layers;
    geoinfo.qualities = qualities;
    geoinfo.layers_relto_surface = layers_relto_surface;
    geoinfo.layers_topo = layers_topo;
    geoinfo.layers_topo_depth = layers_topo_depth;    
    
>>>>>>> Stashed changes
    geoinfo.peakim(geoinfo.peakim<tp.seedthresh) = 0; % Only needed for old data files
    tp.rows = geoinfo.tp.rows;
    tp.clms = geoinfo.tp.clms;
    tp.num_bottom_peaks = geoinfo.tp.num_bottom_peaks;
end

% Create background plot.
f1 = figure(1);

if strcmpi(opt.input_type, 'MCoRDS')
    imagesc(tp.clms,geoinfo.twt,(mag2db(geoinfo.data)));
elseif strcmpi(opt.input_type, 'GPR_LF')
    imagesc(tp.clms,geoinfo.twt,geoinfo.data);
    caxis([-0.05,0.01])
end
colormap(bone)
colorbar
hold on

% Include and update surface and bottom pick.
update_plot = 1;
manual_MBFBP = 0;
MinBinBottom = ones(1,geoinfo.num_trace) * tp.MinBinForBottomPick;
<<<<<<< Updated upstream
dt=geoinfo.time_range(2)-geoinfo.time_range(1);
t1=geoinfo.time_range(1);
=======
MaxBinBottom = ones(1,geoinfo.num_trace) * min(tp.MaxBinForBottomPick, length(tp.rows));
dt=geoinfo.twt(2)-geoinfo.twt(1);
t1=geoinfo.twt(1);
>>>>>>> Stashed changes
while update_plot
    if manual_MBFBP
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
<<<<<<< Updated upstream
        geoinfo = pick_surface(geoinfo,geoinfo.echogram,tp.MinBinForSurfacePick,tp.smooth_sur);
        geoinfo = pick_bottom(geoinfo, tp, MinBinBottom);
=======
        geoinfo = pick_surface(geoinfo,geoinfo.data,tp.MinBinForSurfacePick,tp.smooth_sur);
        geoinfo = pick_bottom(geoinfo, tp, opt, MinBinBottom, MaxBinBottom);
>>>>>>> Stashed changes
    end

    % Lines for testting: delete if finished.
    %geoinfo = pick_bottom(geoinfo,tp.MinBinForBottomPick,tp.smooth_bot, tp.num_bottom_peaks);
    %opt.update_bottom = 1


    % Delete existing surface and bottom pick
    if exist('botplot','var')
        delete(surplot);
        delete(minplot);
        delete(botplot);
    end

    MinBinBottomPlot=(MinBinBottom*dt)+t1;
    % plot new surface and bottom pick
    surplot = plot(tp.clms,geoinfo.traveltime_surface,'Linewidth',2, 'Color', [0    0.4470    0.7410]);
    hold on
    minplot = plot(tp.clms,MinBinBottomPlot, 'k--');
    hold on
    botplot = plot(tp.clms,geoinfo.traveltime_bottom,'Linewidth',2, 'Color', [0.8500    0.3250    0.0980]);
    hold on
    %set(gcf,'doublebuffer','on');

    if opt.update_bottom
        disp('Show surface and bottom picks.')

        prompt = {'Number of bottom peaks:','Pick MinBinForBottomPick manually (1=yes, 0=no):'};
        dlgtitle = 'Update bottom pick?';
        dims = [1 35];
        definput = {int2str(tp.num_bottom_peaks),'0'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        update_plot = ~isempty(answer);
        if update_plot
            tp.num_bottom_peaks = str2double(answer{1});
            manual_MBFBP = str2double(answer{2});
            disp('Processing new bottom pick...')
        end
    else
        update_plot = 0;
    end
end

<<<<<<< Updated upstream
if opt.update_bottom
        minscales=3;
    scales = minscales:tp.maxwavelet; % definition from ARESELP

    %calculate seedpoints
    [~,imAmp, ysrf,ybtm] = preprocessing(geoinfo);
    peakim = peakimcwt(imAmp,scales,tp.wavelet,ysrf,ybtm,tp.bgSkip); % from ARESELP
    geoinfo.peakim = peakim;
    geoinfo.peakim(geoinfo.peakim<tp.seedthresh) = 0; %

    clear peakim imAmp ysrf ybtm echogram scales


    [geoinfo.psX,geoinfo.psY] = ll2ps(geoinfo.latitude,geoinfo.longitude); %convert to polar stereographic
=======
if ~isfield(opt,'update_seeds')
    opt.update_seeds = 0;
end
>>>>>>> Stashed changes

if opt.update_bottom || opt.update_seeds
    if strcmpi(opt.input_type, 'MCoRDS')
        minscales=3;
        scales = minscales:tp.maxwavelet; % definition from ARESELP

        %calculate seedpoints
        [~,imAmp, ysrf,ybtm] = preprocessing(geoinfo);
        peakim = peakimcwt(imAmp,scales,tp.wavelet,ysrf,ybtm,tp.bgSkip); % from ARESELP
        geoinfo.peakim = peakim;
        geoinfo.peakim(geoinfo.peakim<tp.seedthresh) = 0; %

        clear peakim imAmp ysrf ybtm echogram scales
    elseif strcmpi(opt.input_type, 'GPR_LF')
        geoinfo.peakim =  zeros(size(geoinfo.data));
    end
    
    if isfile(opt.filename_geoinfo) && opt.keep_old_picks
        geoinfo_old = load(opt.filename_geoinfo);
        geoinfo.num_layer = geoinfo_old.num_layer;
<<<<<<< Updated upstream
        geoinfo.layers = geoinfo_old.layers;
        geoinfo.qualities = geoinfo_old.qualities;
=======
        clms_old = geoinfo_old.tp.clms;
        clms_new = tp.clms;
        clms_old_min = max(1,clms_new(1)-clms_old(1)+1);
        clms_old_max = min(length(clms_old),clms_new(end)-clms_old(1)+1);
        clms_new_min = max(1,clms_old(1)-clms_new(1)+1);
        clms_new_max = min(length(clms_new),clms_old(end)-clms_new(1)+1);
        
        geoinfo.layers = NaN(nol,geoinfo.num_trace);
        geoinfo.layers_relto_surface = NaN(nol,geoinfo.num_trace);
        geoinfo.layers_topo = NaN(nol,geoinfo.num_trace);
        geoinfo.layers_topo_depth = NaN(nol,geoinfo.num_trace);
        geoinfo.qualities = NaN(nol,geoinfo.num_trace);


        if isfield(geoinfo_old,'layers')
            nool = size(geoinfo_old.layers,1); % number of old layers
            geoinfo.layers(1:nool, clms_new_min:clms_new_max) = geoinfo_old.layers(:, clms_old_min:clms_old_max);
            geoinfo.layers_relto_surface(1:nool, clms_new_min:clms_new_max) = geoinfo_old.layers_relto_surface(:, clms_old_min:clms_old_max);
            geoinfo.layers_topo(1:nool, clms_new_min:clms_new_max) = geoinfo_old.layers_topo(:, clms_old_min:clms_old_max);
            geoinfo.layers_topo_depth(1:nool, clms_new_min:clms_new_max) = geoinfo_old.layers_topo_depth(:, clms_old_min:clms_old_max);
            geoinfo.qualities(1:nool, clms_new_min:clms_new_max) = geoinfo_old.qualities(:, clms_old_min:clms_old_max);
        end
>>>>>>> Stashed changes
        clear geoinfo_old
    end
    geoinfo.tp = tp;
    save(opt.filename_geoinfo, '-struct', 'geoinfo')
end
