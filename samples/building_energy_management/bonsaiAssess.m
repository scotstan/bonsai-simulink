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
    assignin('base', 'nWindows_room1', episodeConfig.input_nWindowsRoom1);
    
    % Error handle to default values if user does not provide # of windows
    try
        assignin('base', 'nWindows_room2', episodeConfig.input_nWindowsRoom2);
    catch
        assignin('base', 'nWindows_room2', 6);
    end
    try
        assignin('base', 'nWindows_room3', episodeConfig.input_nWindowsRoom3);
    catch
        assignin('base', 'nWindows_room3', 6);
    end
end
