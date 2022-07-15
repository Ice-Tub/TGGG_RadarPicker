function [geoinfo] = readdata(filename, inputtype, rows, clms)
%--------------------------------------------------------------
% Read geoinfo and other Meta info from MATFILE
%
% Parameters
% ----------
% filename : name of .mat file
%       tp : structure with tuning parameters
%
% See also
% --------
%   netcdf_to_mat.m
%   convert2mat.m
%  
% Returns
% -------
% geoinfo : struct 
%   Containing geoinformation
% echogram : 2-D image
%   MCoRDS echogram
%
% Examples
% --------
% [geoinfo] = read_data('Data_20110329_02_019.mat');
%---------------------------------------------------------------
    % extract geoinformation and other Meta data from datasets
    input = load(filename);
    
    if strcmpi(inputtype, 'MCoRDS')
        data = input.Data;
        twt = input.Time;
        twt_sur = input.Surface;
        twt_bot = zeros(length(twt_sur));
        lat = input.Latitude;
        lon = input.Longitude;
        psX = input.psX;
        psY = input.psY;
        elevation_sur = input.DemElevation; % Have to use Elevation?
        time_gps = input.GPS_time;
        
    elseif strcmpi(inputtype, 'GPR_LF')
        org_name = fields(input);
        input = input.(org_name{1});
        
        data = input.wfm;
        twt = input.twt';
        twt_sur = zeros(length(input.lat));
        twt_bot = zeros(length(input.lat));
        lat = input.lat;
        lon = input.lon;
        psX = input.x;
        psY = input.y;
        elevation_sur = input.z;
        time_gps = input.gpsclock;
        
    elseif strcmp(inputtype, 'GPR_HF')
        org_name = fields(input);
        input = input.(org_name{1});
        
        % process data
        hil = hilbert(input.wfm);
        env = abs(hil);
        smoothed_env = movmedian_2d(env, 20);
        norm_env = smoothed_env/max(smoothed_env, [], 'all');
     
        
        data = norm_env;
        psX = input.x;
        psY = input.y; 
        elevation_sur = input.z; 
        dt = 0.2931; % which unit? This is sampling interval, can I use it to calculate TWT?
        twt = (1:size(data,1))' * dt * 1e-9; % calculate TWT for GPR_HF data 
        
        % initialize data that does not exist for GPR_HF
        lat = NaN(1, size(data,2));
        lon = NaN(1, size(data,2));
        time_gps = NaN(size(data,2), 1);
        twt_sur = zeros(length(lat));
        twt_bot = NaN(length(lat));
        
    elseif strcmp(inputtype, 'awi_flight')
        
        data = input.wfm;
        twt = input.twt';
        twt_sur = NaN(length(input.lat));
        twt_bot = NaN(length(input.lat));
        lat = input.lat;
        lon = input.lon;
        psX = input.x;
        psY = input.y;
        elevation_sur = input.z;
        time_gps = NaN(size(data,2), 1);

    elseif strcmp(inputtype, 'pulsEKKO')
        
        data = input.data;
        twt = input.travel_time';
        twt_sur = NaN(length(input.lat));
        twt_bot = NaN(length(input.lat));
        lat = input.lat;
        lon = input.long;
        psX = input.x_coord;
        psY = input.y_coord;
        elevation_sur = input.elev;
        time_gps = NaN(size(data,2), 1);
                
    else
        disp(append("Inputfile type '", inputtype ,"' is unknown."))
    end
        
    if nargin == 3
        data = data(rows, :); % Only cut of rows
        twt = twt(rows, 1);
    elseif nargin > 3
        if ischar(clms)
            if strcmp(clms, 'all_clms')
                clms = 1:size(data,2);
            end
        end
        data = data(rows, clms);
        twt = twt(rows);
        twt_sur = twt_sur(clms);
        twt_bot = twt_bot(clms);
        lat = lat(clms);
        lon = lon(clms);
        psX = psX(clms);
        psY = psY(clms);
        elevation_sur = elevation_sur(clms);
        time_gps = time_gps(clms);
    end
    
    x_dist = psX - psX(1); 
    y_dist = psY - psY(1);
    dist = sqrt(x_dist.^2 + y_dist.^2);
    num_trace = length(lat);
    num_layer = [];
    
    if dist(end) > 1000
         dist = dist/1000;
    end
    
    geoinfo.data = data; 
    geoinfo.twt = twt;
    geoinfo.twt_sur = twt_sur;
    geoinfo.twt_bot = twt_bot;
    geoinfo.lat = lat;
    geoinfo.lon = lon;
    geoinfo.psX = psX;
    geoinfo.psY = psY;
    geoinfo.elevation_sur = elevation_sur;
    geoinfo.time_gps = time_gps;
    geoinfo.dist = dist;
    geoinfo.num_trace = num_trace;
    geoinfo.num_layer = num_layer;
    
end