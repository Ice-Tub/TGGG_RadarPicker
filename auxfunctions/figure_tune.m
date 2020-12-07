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
    geoinfo = readdata2(opt.filename_raw_data,tp.rows,tp.clms); % from ARESELP
    opt.update_bottom = 1;
elseif ~isfile(opt.filename_geoinfo)
    geoinfo = readdata2(opt.filename_raw_data,tp.rows,tp.clms); % from ARESELP
    opt.update_bottom = 1;
else
    geoinfo = load(opt.filename_geoinfo);
    geoinfo.peakim(geoinfo.peakim<tp.seedthresh) = 0; % Only needed for old data files
    tp.rows = geoinfo.tp.rows;
    tp.clms = geoinfo.tp.clms;
    tp.num_bottom_peaks = geoinfo.tp.num_bottom_peaks;
end

% Create background plot.
f1 = figure(1);
imagesc(tp.clms,geoinfo.time_range,(mag2db(geoinfo.echogram)));
colormap(bone)
colorbar
hold on

% Include and update surface and bottom pick.
update_plot = 1;
manual_MBFBP = 0;
MinBinBottom = ones(1,geoinfo.num_trace) * tp.MinBinForBottomPick;
dt=geoinfo.time_range(2)-geoinfo.time_range(1);
t1=geoinfo.time_range(1);
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
        geoinfo = pick_surface(geoinfo,geoinfo.echogram,tp.MinBinForSurfacePick,tp.smooth_sur);
        geoinfo = pick_bottom(geoinfo, tp, MinBinBottom);
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

    if isfile(opt.filename_geoinfo) && opt.keep_old_picks
        geoinfo_old = load(opt.filename_geoinfo);
        geoinfo.num_layer = geoinfo_old.num_layer;
        geoinfo.layers = geoinfo_old.layers;
        geoinfo.qualities = geoinfo_old.qualities;
        clear geoinfo_old
    end

    geoinfo.tp = tp;
    save(opt.filename_geoinfo, '-struct', 'geoinfo')
end
