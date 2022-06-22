function [metadata] = initialize_metadata(geoinfo, opt)
%CREATE_METADATA Summary of this function goes here
%   Detailed explanation goes here
metadata.coordinator = opt.coordinator;
metadata.operator = opt.picker;
metadata.lat = geoinfo.lat;
metadata.lon = geoinfo.lon;
metadata.psX = geoinfo.psX;
metadata.psY = geoinfo.psY;
metadata.twt = geoinfo.twt;
metadata.frequency = opt.frequency;
metadata.crossover = {};
metadata.pickingDates(1:opt.nol) = {'not picked'};
metadata.interruptions(1:opt.nol) = "not picked";

if strcmp(opt.input_type, 'GPR_LF')
    metadata.radarType = 'Ground-based dipole antennae';
elseif strcmp(opt.input_type, 'MCoRDS')
    metadata.radarType = 'airborne MCoRDS';
end

end

