function [metadata] = initialize_metadata(geoinfo, opt)
%CREATE_METADATA Summary of this function goes here
%   Detailed explanation goes here
metadata.coordinator = opt.coordinator;
metadata.picker = opt.picker;
metadata.lat = geoinfo.lat;
metadata.lon = geoinfo.lon;
metadata.psX = geoinfo.psX;
metadata.psY = geoinfo.psY;
metadata.twt = geoinfo.twt;
metadata.radarType = opt.input_type;
metadata.frequency = opt.frequency;
metadata.crossover = {};
metadata.pickingDates(1:opt.nol) = {'not picked'};
metadata.interruptions(1:opt.nol) = {'not picked'};

end

