function save_metadata(opt, metadata)
%SAVE_METADATA Save metadata
%   

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

