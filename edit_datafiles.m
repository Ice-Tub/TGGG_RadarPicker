clear all;
close all;
addpath(append(pwd,'\auxfunctions'))

% Settings
move_option = 'swap' ; % Options: 'swap', 'overwrite', 'view' or 'update'.
data_folder = 'data\MCoRDS_picked_corrected';
move_from_file = 'LayerData_06_02_006';
move_from_layer = 4;
move_to_file = 'LayerData_06_02_006';

move_to_layer = 6;

edit_data(move_option, data_folder, move_from_file, move_from_layer, move_to_file, move_to_layer);