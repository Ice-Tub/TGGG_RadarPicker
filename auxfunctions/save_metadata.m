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


% check if old metadata exists and, if so, replace the dates of newly
% picked layers
if isfile(opt.file_metadata)
    oldMetadata = load(opt.file_metadata);
    for ii = 1:opt.nol
        if ~strcmp(oldMetadata.pickingDates{ii}, 'not picked')
            if strcmp(metadata.pickingDates{ii}, 'not picked')
                metadata.pickingDates{ii} = oldMetadata.pickingDates{ii}; 
            end
        end
    end  
end

save(opt.file_metadata, '-struct', 'metadata');

end

