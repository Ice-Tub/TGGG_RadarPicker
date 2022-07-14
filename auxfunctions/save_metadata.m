function save_metadata(opt, geoinfo, metadata)
%SAVE_METADATA Save metadata
%   

%compute interruptions in layer for metadata
for ii = 1:opt.nol
    metadata.interruptions(ii) = compute_interruption(geoinfo.layers(ii,:));
end

% save picked layers with bins and twt in metadata
dt = geoinfo.twt(2) - geoinfo.twt(1);
metadata.IRH_bin = geoinfo.layers;
metadata.IRH_twt = geoinfo.layers .* dt;
metadata.qualities = geoinfo.qualities;

% save row containing filename etc. for each trace
metadata.filename = repmat({opt.input_file}, 1, size(metadata.IRH_bin,2));
metadata.acquisition_day = repmat(opt.acquisition_day, 1, size(metadata.IRH_bin,2));
metadata.acquisition_month = repmat(opt.acquisition_month, 1, size(metadata.IRH_bin,2));
metadata.acquisition_year = repmat(opt.acquisition_year, 1, size(metadata.IRH_bin,2));
metadata.survey_number = repmat(opt.survey_number, 1, size(metadata.IRH_bin,2));
metadata.profile_number = repmat(opt.profile_number, 1, size(metadata.IRH_bin,2));
metadata.trace = 1:size(metadata.IRH_bin,2);
metadata.picking_date = repmat(opt.picking_date, 1, size(metadata.IRH_bin,2));

save(opt.file_metadata, '-struct', 'metadata');

end

