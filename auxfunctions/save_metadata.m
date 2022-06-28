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

save(opt.file_metadata, '-struct', 'metadata');

end

