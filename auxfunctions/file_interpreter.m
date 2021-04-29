function [opt] = file_interpreter(opt)
%FILE_INTERPRETER interprets the input filename settings.
%   Detailed explanation goes here
    if ~contains(opt.input_file, '.mat')
        opt.input_file = append(opt.input_file, '.mat');
    end
    if ~contains(opt.output_suffix, '.mat')
        opt.output_suffix = append(opt.output_suffix, '.mat');
    end

    opt.filename_input_data = append(pwd, opt.input_folder, opt.input_file); % Inputfile not needed if geoinfofile already exists.
    opt.filename_geoinfo = append(pwd, opt.output_folder, opt.output_prefix, opt.output_suffix);
    if opt.load_crossover
        filenames_cross = {};
        if strcmp(opt.cross_section,'all')
            cross_struct = dir(append(pwd, opt.output_folder,'\*.mat'));
            opt.n_cross = length(cross_struct);
            for k = 1:opt.n_cross
                filename_cross = append(cross_struct(k).folder, '\', cross_struct(k).name);
                filenames_cross = [filenames_cross; filename_cross];
            end
        else
            if ischar(opt.cross_section)
                opt.cross_section = {opt.cross_section};
            end
            opt.n_cross = numel(opt.cross_section);
            for k = 1:opt.n_cross
                filename_cross = append(pwd,opt.output_folder,opt.output_prefix,opt.cross_section{k},'.mat');
                filenames_cross = [filenames_cross; filename_cross];
            end
        end
        opt.filenames_cross = setdiff(filenames_cross, {opt.filename_geoinfo});
        opt.n_cross = length(opt.filenames_cross);
    end
end

