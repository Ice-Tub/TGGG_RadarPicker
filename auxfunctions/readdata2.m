function [geoinfo,echogram] = readdata(filename, rows, clms)
%--------------------------------------------------------------
% Read geoinfo and other Meta info from MATFILE
%
% Parameters
% ----------
% filename : mat file
%   MCoRDS Mat file
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
% [geoinfo, echogram] = read_data('Data_20110329_02_019.mat');
%---------------------------------------------------------------
    Bottom = clms*0.0+11e-6; %set initial bottom pick as horizontal line (was implemented as a function argument before)
    
    C = 3e8; EPSILON = 3.15;
    % extract geoinformation and other Meta data from datasets
    load(filename);
    Data=Data;
    
    if nargin < 2
        [Height, Width] = size(Data);
        Data = Data(1:Height,1:Width); %load the whole data set
    end
    
    if nargin == 2
        [Height, Width] = size(Data);
        Data = Data(rows,1:Width); % in this option only certain rows would be cut off
        Time = Time (rows, 1);
    end
   
    if nargin > 2
        Data = Data (rows, clms);
        Surface=Surface(1, clms);
        Bottom=Bottom(1, clms);
        Elevation= DemElevation (1, clms);
        Latitude = Latitude (1, clms);
        Longitude = Longitude (1, clms);
        GPS_time=GPS_time(1, clms);
        Time = Time (rows, 1);
    end
    
    echogram = Data;
 
    fdnames = {'distance','elevation_bed','elevation_surface',...
        'latitude','longitude','num_layer','num_trace','thickness',...
        'time_gps','traveltime_surface','x','y','layer',...
        'traveltime_bottom','time_range'}; %last two fields added by XST
    
    ntcfield = 11;
    ntrace = size(Data,2);
    traceData = zeros(ntcfield,ntrace);
    
    traceData(4,:) = Latitude;
    traceData(5,:) = Longitude;
    %Modified RD, this seems odd and gives too large x spacing
    %[x,y] = polarstereo_fwd(Latitude,Longitude,6378137.0,0.08181919,70,-45);
    [x,y] = ll2ps(Latitude,Longitude);  
    x = x - x(1); y = y - y(1);
    distance = sqrt(x.^2 + y.^2);
    if distance(end) > 1000
         distance = distance/1000;
    end
    traceData(1,:) = distance;
    traceData(9,:) = x;
    traceData(10,:) = y;
    traceData(7,:) = GPS_time;
    traceData(8,:) = Surface;
    %next 4 lines edited IK 2020/08/04
    %Bottom = Surface*0.0+11e-6 ; 
    traceData(11,:) = Bottom; 
    traceData(6,:) = (Bottom - Surface)*C/2/sqrt(EPSILON); % thickness
    %traceData(3,:) = Elevation - Surface*C/2; % elevation_surface
    traceData(3,:) = Elevation; % elevation_surface
    traceData(2,:) = traceData(3,:) - traceData(6,:);
    
    if traceData(1,2) == 0
        geoinfo = struct(fdnames{1},[]);
    else
        geoinfo = struct(fdnames{1},traceData(1,:));
    end
    
    ndata = 2;
    for i = 2:length(fdnames)
        switch i
            case 6
                geoinfo.num_layer = [];
%                 nfd = nfd + 1;
            case 7
                geoinfo.num_trace = ntrace;
%                nfd = nfd + 1;
%            case 13
%                geoinfo.layer = [];
%                nfd = nfd + 1;
            case 15
                geoinfo.time_range = Time;
            otherwise
                geoinfo.(fdnames{i}) = traceData(ndata,:);
                ndata = ndata + 1;
        end
        
    end

end