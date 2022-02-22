function save_metadata(opt, metadata)
%SAVE_METADATA Save metadata
%   

% check if old metadata exists and, if so, replace the new points
if isfile(opt.file_metadata)
    oldMetadata = load(opt.file_metadata);
    for ii = 1:opt.nol
        layerName = strcat('Layer', sprintf('%u', ii));
        layerDate = strcat('Layer', sprintf('%u', ii), '_date');
        layerInterruptions = strcat('Layer', sprintf('%u', ii), '_interruption');

        % check if old metadata contains layers which are either not
        % included in metadata or outdated
        if isfield(oldMetadata, layerName)
            if ~isfield(metadata, layerName)
                metadata.(layerName) = oldMetadata.(layerName);
                metadata.(layerDate) = oldMetadata.(layerDate);
                metadata.(layerInterruptions) = oldMetadata.(layerInterruptions);
            end

        end
    end  
end
save(opt.file_metadata, '-struct', 'metadata');
end

