function [opt] = file_interpreter(opt)
%FILE_INTERPRETER handles the input file settings.
%   This function interprets the file settings made by the user.
%
%   It ensures the existance of the .mat-file extension and if paths for
%   the input, output and crossover files are given as relative paths, it
%   turns them into absolute paths, which can more easily be used in the
%   following.
%
%   Falk Oraschewski, 09.09.2022

% Ensure filename extension included in input and output files.
if ~contains(opt.input_file, '.mat')
    opt.input_file = append(opt.input_file, '.mat');
end
if ~contains(opt.output_suffix, '.mat')
    opt.output_suffix = append(opt.output_suffix, '.mat');
end

% Remove initial slashes in folder paths, if existing.
if strcmp(opt.input_folder(1),'/') || strcmp(opt.input_folder(1),'\')
    opt.input_folder = opt.input_folder(2:end);
end
if strcmp(opt.output_folder(1),'/') || strcmp(opt.output_folder(1),'\')
    opt.output_folder = opt.output_folder(2:end);
end
if strcmp(opt.metadata_folder(1),'/') || strcmp(opt.metadata_folder(1),'\')
    opt.metadata_folder = opt.metadata_folder(2:end);
end

% Turn relative paths into absolut paths.
% Get full input filename (Not needed if geoinfo file already exists)
input_path = dir(fullfile(opt.input_folder, opt.input_file)); % Obtain abolute path and file name, independent of 'opt.input_folder' being an absolute or relative path.
if ~isempty(input_path)  % Only need to process input file if it is not empty, which might be sufficient when working with existing LayerData files.
    opt.filename_input_data = fullfile(input_path.folder, input_path.name); % Get the full input file name.
end

% Get full output filename
output_path = dir(opt.output_folder); % Obtain absolute output path.
output_file = append(opt.output_prefix, opt.output_suffix); % Merge output prefix and suffix
opt.filename_geoinfo = fullfile(output_path(1).folder, output_file);

% Get full metadata filename
metadata_path = dir(opt.metadata_folder);
metadata_file = append(opt.metadata_prefix, opt.output_suffix);
opt.filename_metadata = fullfile(metadata_path(1).folder, metadata_file);

% Obtain absolute paths to crossover files.
if opt.load_crossover
    cross_struct = dir(fullfile(opt.output_folder, '*.mat'));
    if strcmp(opt.cross_section,'all')
        filenames_cross = fullfile({cross_struct.folder}, {cross_struct.name});
    else
        cross_file = append(opt.output_prefix, opt.cross_section, '.mat');
        filenames_cross = fullfile(cross_struct(1).folder, cross_file);
    end
    % Remove active profile from cross profile list.
    opt.filenames_cross = setdiff(filenames_cross, {opt.filename_geoinfo});
    % Obtain number of cross profiles.
    opt.n_cross = length(opt.filenames_cross);
end

end

