function [opt] = input_interpreter(opt)
%IPNUT_INTERPRETER infers further settings depending on tpye of input
%settings.
%   Detailed explanation goes here
%
%   Derived options are always included such that they can, but do not need
%   to be set in the input settings.
%
%   Falk Oraschewski, 09.09.2022



opt = file_interpreter(opt); % Interpret input settings for filenames.


% Ensure that option to turn off bottom pick exists.
if ~isfield(opt,'exist_bottom')
    opt.exist_bottom = 1;
end
% Deactivate bottom pick for shallow data types.
if (strcmpi(opt.input_type, 'GPR_HF') || strcmpi(opt.input_type, 'awi_flight'))
    opt.exist_bottom = 0;
end


if ~isfield(opt,'manual_bottom_pick')
    opt.manual_bottom_pick = 0;
end

if ~isfield(opt,'update_bottom')
    opt.update_bottom = 0;
end

% Ensure that option to update seed points exists.
if ~isfield(opt,'update_seeds')
    opt.update_seeds = 0;
end
% Ensure that seed points are updated, when bottom pick is updated.
if opt.update_bottom 
    opt.update_seeds = 1;
end
end

