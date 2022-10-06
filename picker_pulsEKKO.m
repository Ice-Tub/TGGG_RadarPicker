clear;
close all;

% - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - -
%IMPROVEMENTS TO IMPLEMENT
% - remarks in interpol_index
% - decouple options, windows, etc. 
% - observe which settings work for which profiles
% - introduce seeds for other input types than MCoRDS
% - load cross-over points for every profile 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Working settings
% Data
opt.coordinator = 'Reinhard Drews';
opt.picker = 'Leah Sophie Muhle, Inka Koch';
opt.frequency = '50 MHz';
opt.picking_date = datetime('today');
opt.acquisition_day = NaN;
opt.acquisition_month = NaN;
opt.acquisition_year = NaN;
opt.survey_number = NaN;
opt.profile_number = NaN; % needs to be a number


opt.input_type = 'PulsEKKO'; %Inputfile-type, options: 'GPR_LF', 'MCoRDS', 'GPR_HF', 'awi_flight', 'PulsEKKO'
opt.input_folder = '/../../data/rd_group/ReMeltRadar/Proc_PE/';
opt.input_file = 'EIS_along1';
opt.output_folder = '/../../data/rd_group/ReMeltRadar/Proc_PE/picks/'; % Relative or absolue path
opt.output_prefix = '/LayerData_'; % Define a prefix for the layerdata-file. (output_file = prefix + suffix)
opt.output_suffix = opt.input_file; % Define a suffix for the layerdata-file.
opt.metadata_folder = '/../../data/rd_group/ReMeltRadar/Proc_PE/picks/metadata/';
opt.metadata_prefix = '/metadata_'; % Define a prefix for the metadata-file. (metadata_file = prefix + suffix)
opt.cross_section = 'EIS_along2'; % Options : List of numbers (e.g.:{'001'; '002'}) or all files in output_folder('all'). Some already pick section to find cross-points.




% Options
% The following options can be activated by setting: 1 = yes, 0 = no.
opt.create_new_geoinfo = 0; % CAUTION: Already picked layer for this echogram will be overwritten, if keep_old_picks = 0.
opt.update_bottom = 1;      % Update bottom, when old geoinfo is loaded.
opt.update_seeds = 1;      % Update bottom, when old geoinfo is loaded.
opt.manual_bottom_pick = 1; % Pick bottom manually, needed for data with intereupted or weak bottom reflector.
opt.keep_old_picks = 1;     % Keep old picks, when old geoinfo is loaded.
opt.load_crossover = 1;     % Activate loading cross-over points.

opt.delete_stripes = 0;     % If activated, the horizontal mean will be subtracted from data.
opt.filter_frequencies = 0; % If activated, frequencies higher than 10 MHz will be filtered from signal; applies only to GPR_LF data
opt.median_peaks = 1;       % If activated, not the intensity peaks, but the median intensities from a tp.window x tp.window environment will be used for findpeaks
opt.interpol_peaks = 0;     % If activated, linear interpolation of all the peaks in a tp.window x tp.window field are computed for layer propagation. This and medianpeaks should not be activated simultaneously. 
opt.nopeak_step = 1;        % Use the previous step instead of the same height for propagate_layer if no local extremum of intensity can be found
opt.find_maxima = 0;        % If activated, maxima are picked. Otherwise minima are picked. 

% Appearance
opt.len_color_range = 0.8;
opt.cmp = 'bone';            % e.g. 'jet', 'bone', 'gray'
opt.editing_window = 10;    % Number of traces that are updated in editing mode.

%%% Tuning parameters
% For cutting the data
tp.clms='all_clms';              % If an existing file is loaded, this option is overwritten.
tp.rows='all_rows';%1:2500;                % cuts the radargram to limit processing (time) (top and bottom)

% For surface and bottom pick
tp.MinBinForSurfacePick = 10; % when already preselected, this can be small
tp.smooth_sur=40;             % between 30 and 60 seems to be good
tp.MinBinForBottomPick = 8000;
tp.MaxBinForBottomPick = 11000;
tp.num_bottom_peaks = 3;      % Number of strongest peaks considered as bottom pick. 10 is a good guess.
tp.smooth_bot = 1;              % Smoothing for bottom pick. No smoothing for smooth_bot 

% For computation of seeds (Only possible for MCoRDS-data)
tp.window = 9;                  %vertical window, keep small to avoid jumping. Even numbers work as next odd number.
tp.seedthresh = 5;              % 5 seems to work ok, make bigger to have less, set 0 to take all (but then the line jumps automatically...)

%wavelet parameters
tp.wavelet = 'mexh';          % choose the wavelet 'mexh' or 'morl' - Mexican Hat (mexh) gives cleaner results
tp.maxwavelet = 16;             %min is always 3, layers size is half the wavelet scale
tp.bgSkip = 150;              %decide how many pixels below bed layer is counted as background noise: default is 50 - makes a big difference for m-exh, higher is better
tp.RefHeight = 300;             %set the maximum height for topo correction of echogram, extended to 5000 since I got an error in some profiles

% Other Parameters
tp.nopeaks_window = 5;       % gives the number of traces over which the direction of layer propagation will be averaged for propagate_layer in case of no peak 
tp.weight_factor = 2;         % states how much the previous direction of layer propagation is weighted in comparison to peak prominence in propagate_layer 
tp.ice_velocity = 1.68e8;     % ice velocity used for topographical correction
%%
addpath(append(pwd,'/auxfunctions'))
geoinfo = run_picker(opt, tp);