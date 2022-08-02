function [opt] = file_interpreter(opt)
%FILE_INTERPRETER interprets the input filename settings.
%   Detailed explanation goes here
    if ~contains(opt.input_file, '.mat')
        opt.input_file = append(opt.input_file, '.mat');
    end
    if ~contains(opt.output_suffix, '.mat')
        opt.output_suffix = append(opt.output_suffix, '.mat');
    end
    
    if strcmp(opt.input_folder(1),'/') || strcmp(opt.input_folder(1),'\')
        opt.input_folder = opt.input_folder(2:end);
    end
    if strcmp(opt.output_folder(1),'/') || strcmp(opt.output_folder(1),'\')
        opt.output_folder = opt.output_folder(2:end);
    end 
    
    % Get full input filename (Not needed if geoinfo file already exists)
    input_path = dir(fullfile(opt.input_folder, opt.input_file)); % Obtain abolute path and file name, independent of 'opt.input_folder' being an absolute or relative path.
    opt.filename_input_data = fullfile(input_path.folder, input_path.name); % Get the full input file name.
    
    % Get full output filename
    output_file = append(opt.output_prefix, opt.output_suffix); % Merge output prefix and suffix
    output_path = dir(fullfile(opt.output_folder, output_file)); % Obtain abolute path and file name, independent of 'opt.output_folder' being an absolute or relative path.
    opt.filename_geoinfo = fullfile(output_path.folder, output_path.name); % Get the full output file name.
    
    if opt.load_crossover
        filenames_cross = {};
        if strcmp(opt.cross_section,'all')
            cross_struct = dir(fullfile(pwd, opt.output_folder,'*.mat'));
            for k = 1:length(cross_struct)
                filename_cross = fullfile(cross_struct(k).folder, cross_struct(k).name);
                filenames_cross = [filenames_cross; filename_cross];
            end
        else
            % ToDO: recheck that this option works
            if ischar(opt.cross_section)
                opt.cross_section = {opt.cross_section};
            end
            for k = 1:numel(opt.cross_section)
                filename_cross = append(pwd,opt.output_folder,opt.output_prefix,opt.cross_section{k},'.mat');
                filenames_cross = [filenames_cross; filename_cross];
            end
        end
        opt.filenames_cross = setdiff(filenames_cross, {opt.filename_geoinfo});
        opt.n_cross = length(opt.filenames_cross);
    end
end

