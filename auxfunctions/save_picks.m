function [outputArg1,outputArg2] = save_picks(filename_geoinfo,geoinfo)
%SAVE_PICKS Summary of this function goes here
%   Detailed explanation goes here
geoinfo.num_layer = sum(max(~isnan(layers),[],2));
geoinfo.layers = layers;
geoinfo.layers_relto_surface = layers_relto_surface;
geoinfo.qualities = qualities;
geoinfo.tp = tp;
%geoinfo.layer1(geoinfoidx,2)=geoinfolayer1_ind; %still keep the overlapping point in the data
save(filename_geoinfo, '-struct', 'geoinfo')

end

