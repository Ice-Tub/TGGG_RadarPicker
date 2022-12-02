function geoinfo = update_geoinfo(geoinfo, current_version, tp)
%%
% ToDo: Include option 'append'
%% Rename fields with depracted names.
if isfield(geoinfo,'echogram')
    geoinfo.data = geoinfo.echogram;
    geoinfo = rmfield(geoinfo,'echogram');
end
if isfield(geoinfo,'time_range')
    geoinfo.twt = geoinfo.time_range;
    geoinfo = rmfield(geoinfo,'time_range');
end
if isfield(geoinfo,'traveltime_surface')
    geoinfo.twt_sur = geoinfo.traveltime_surface;
    geoinfo = rmfield(geoinfo,'traveltime_surface');
end
if isfield(geoinfo,'traveltime_bottom')
    geoinfo.twt_bot = geoinfo.traveltime_bottom;
    geoinfo = rmfield(geoinfo,'traveltime_bottom');
end
if isfield(geoinfo,'latitude')
    geoinfo.lat = geoinfo.latitude;
    geoinfo = rmfield(geoinfo,'latitude');
end
if isfield(geoinfo,'longitude')
    geoinfo.lon = geoinfo.longitude;
    geoinfo = rmfield(geoinfo,'longitude');
end
if isfield(geoinfo,'elevation_surface')
    geoinfo.elevation_sur = geoinfo.elevation_surface;
    geoinfo = rmfield(geoinfo,'elevation_surface');
end
if isfield(geoinfo,'distance')
    geoinfo.dist = geoinfo.distance;
    geoinfo = rmfield(geoinfo,'distance');
end
if isfield(geoinfo,'elevation_bed')
    geoinfo = rmfield(geoinfo,'elevation_bed');
end
if isfield(geoinfo,'thickness')
    geoinfo = rmfield(geoinfo,'thickness');
end
if isfield(geoinfo,'x')
    geoinfo = rmfield(geoinfo,'x');
end
if isfield(geoinfo,'y')
    geoinfo = rmfield(geoinfo,'y');
end
if isfield(geoinfo,'time_pick_abs')
    geoinfo = rmfield(geoinfo,'time_pick_abs');
end


%% Include missing fields
if ~isfield(geoinfo,'ind')
    geoinfo.ind = 1:length(geoinfo.twt);
    [~, geoinfo.ind_sur] = min(abs(geoinfo.twt_bot - geoinfo.twt));
    [~, geoinfo.ind_bot] = min(abs(geoinfo.twt_bot - geoinfo.twt));
    if isempty(geoinfo.ind_bot)
        geoinfo.ind_bot = NaN(1, length(geoinfo.lat));
    end 
end

if ~isfield(geoinfo,'tp')
    geoinfo.tp = tp;
end

geoinfo.version = current_version;
end