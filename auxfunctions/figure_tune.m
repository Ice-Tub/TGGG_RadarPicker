function [geoinfo, tp] = figure_tune(geoinfo,tp,opt)
%FIGURE_TUNE displays the function for surface and bottom picking.
%   Detailed explanation goes here

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
MaxBinBottom = ones(1,geoinfo.num_trace) * min(tp.MaxBinForBottomPick, length(tp.rows));
dt=geoinfo.twt(2)-geoinfo.twt(1);
t1=geoinfo.twt(1);
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
        geoinfo = pick_surface(geoinfo,tp,opt);
        geoinfo = pick_bottom(geoinfo,tp,opt,MinBinBottom,MaxBinBottom);
    end

    % Delete existing surface and bottom pick
    if exist('botplot','var')
        delete(surplot);
        delete(minplot);
        delete(botplot);
        delete(maxplot);
    end

    MinBinBottomPlot=(MinBinBottom*dt)+t1;
    % plot new surface and bottom pick
    surplot = plot(tp.clms,geoinfo.twt_sur,'Linewidth',2, 'Color', [0    0.4470    0.7410]);
    hold on
    minplot = plot(tp.clms,MinBinBottomPlot, 'k--');
    hold on
    botplot = plot(tp.clms,geoinfo.twt_bot,'Linewidth',2, 'Color', [0.8500    0.3250    0.0980]);
    hold on
    maxplot = plot(tp.clms,MaxBinBottomPlot, 'k--');
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
    
    geoinfo.tp = tp;
end
