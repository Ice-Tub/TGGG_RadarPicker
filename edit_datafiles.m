clear all;
close all;
addpath(append(pwd,'\auxfunctions'))

% Settings
move_option = 'view' ; % Options: 'swap', 'overwrite' or 'view'
data_folder = 'picked layers';
move_from_file = 'LayerData_06_02_002';
move_from_layer = 9;
move_to_file = 'LayerData_06_02_002';
move_to_layer = 1;

edit_data(move_option, data_folder, move_from_file, move_from_layer, move_to_file, move_to_layer);