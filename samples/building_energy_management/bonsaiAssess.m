% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Script to configure assessment of your trained Bonsai brain. Assessment can be
% run in 3 steps:
%   1. run this script to configure an assessment session and set required variables
%   2. open the model and click "Run"
%   3. begin assessmnet in the web, selecting the simulator.

% load model and disable fast restart
init_vars
mdl = 'buildingEnergyManagement';
load_system(mdl);
set_param(mdl, 'FastRestart', 'off');

% configure assessment
config = bonsaiConfig;
BonsaiConfigureAssessment(config, mdl, @episodeStartCallback);

% any initial data required for compilation should go here
initToutdoor = 60;

% callback for provided episode configuration
function episodeStartCallback(mdl, episodeConfig)
    assignin('base', 'initToutdoor', episodeConfig.input_Toutdoor);
    assignin('base', 'n_rooms', episodeConfig.input_nRooms);
    assignin('base', 'numWindows_room_1', episodeConfig.input_nWindowsRoom1);
    assignin('base', 'numWindows_room_2', episodeConfig.input_nWindowsRoom2);
    assignin('base', 'numWindows_room_3', episodeConfig.input_nWindowsRoom3);
end
