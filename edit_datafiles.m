clear all;
close all;
addpath(append(pwd,'\auxfunctions'))

% Settings
move_option = 'update' ; % Options: 'swap', 'overwrite', 'view' or 'update'.
data_folder = 'data\picked_mcords';
move_from_file = 'LayerData_002';
move_from_layer = 1;
move_to_file = 'LayerData_002';
move_to_layer = 1;

edit_data(move_option, data_folder, move_from_file, move_from_layer, move_to_file, move_to_layer);