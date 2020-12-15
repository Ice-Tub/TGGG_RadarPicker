clear all;
close all;
addpath(append(pwd,'\auxfunctions'))

% Settings
move_option = 'swap' ; % Options: 'overwrite' or 'swap'
data_folder = 'picked layers';
move_from_file = 'LayerData_009';
move_from_layer = 2;
move_to_file = 'LayerData_009';
move_to_layer = 3;

edit_data(move_option, data_folder, move_from_file, move_from_layer, move_to_file, move_to_layer)