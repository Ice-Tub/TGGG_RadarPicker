clear all;
close all;

% Working settings
% Data
opt.input_type = 'MCoRDS'; %Inputfile-type, options: 'GPR_LF', 'MCoRDS'
opt.input_folder = '\..\..\..\..\..\data\foraschewski\data_large\Radar\mcords_data';
opt.input_file = '\TopoData_20190107_02_001';
opt.output_folder = '\..\..\..\..\..\data\foraschewski\data_large\Radar\mcords_data\picked_mcords';
opt.output_prefix = '\LayerData_'; % Define a prefix for the layerdata-file. (output_file = prefix + suffix)
opt.output_suffix = 'data2010120'; % Define a suffix for the layerdata-file.
opt.cross_section = 'all'; % Options : List of numbers (e.g.:{'001'; '002'}) or all files in output_folder('all'). Some already pick section to find cross-points.
% Options
% The following options can be activated by setting: 1 = yes, 0 = no.
opt.create_new_geoinfo = 0; % CAUTION: Already picked layer for this echogram will be overwritten, if keep_old_picks = 0.
opt.update_bottom = 1;      % Update bottom, when old geoinfo is loaded.
opt.update_seeds = 1;       % This option can be used to update seeds only, if bottom is updated or a new geoinfo is created, the seeds will be computed in any case.
opt.keep_old_picks = 1;     % Keep old picks, when old geoinfo is loaded.
opt.load_crossover = 0;     % Activate loading cross-over points.
opt.delete_stripes = 0;     % If activated, the horizontal mean will be subtracted from data.
% Appearance
opt.len_color_range = 100;
opt.cmp = 'jet';            % e.g. 'jet', 'bone'
opt.editing_window = 10;    % Number of traces that are updated in editing mode.

%%% Tuning parameters
% For cutting the data
tp.clms='full';               % Inert a range or 'full' to load the full profile. If an existing file is loaded, this option is overwritten.
tp.rows=200:800;                %cuts the radargram to limit processing (time) (top and bottom)
% For surface and bottom pick
tp.MinBinForSurfacePick = 10; % when already preselected, this can be small
tp.smooth_sur=40;             %between 30 and 60 seems to be good
tp.MinBinForBottomPick = 300;
tp.MaxBinForBottomPick = 400;
tp.num_bottom_peaks = 5;      % Number of strongest peaks considered as bottom pick. 10 is a good guess.
tp.smooth_bot=1;              % Smoothing for bottom pick. No smoothing for smooth_bot 
% For computation of seeds (Only possible for MCoRDS-data.
tp.window=9;                  %vertical window, keep small to avoid jumping. Even numbers work as next odd number.
tp.seedthresh=5;              % 5 seems to work ok, make bigger to have less, set 0 to take all (but then the line jumps automatically...)
%wavelet parameters
tp.wavelet = 'mexh';          % choose the wavelet 'mexh' or 'morl' - Mexican Hat (mexh) gives cleaner results
tp.maxwavelet=16;             %min is always 3, layers size is half the wavelet scale
tp.bgSkip = 50;              %decide how many pixels below bed layer is counted as background noise: default is 50 - makes a big difference for m-exh, higher is better
tp.RefHeight=600;             %set the maximum height for topo correction of echogram, extended to 5000 since I got an error in some profiles

%%
addpath(append(pwd,'\auxfunctions'))
geoinfo = run_picker(opt, tp);
