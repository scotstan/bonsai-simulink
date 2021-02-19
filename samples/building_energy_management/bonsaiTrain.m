% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Main entrypoint for training a Bonsai brain. After starting this script you
% must begin training your brain in the web, selecting the "Simulink Cartpole"
% simulator.

% Load startupFiles 
init_vars

% load model and enable fast restartd
mdl = 'buildingEnergyManagement';
load_system(mdl);
set_param(mdl, 'FastRestart', 'on');

% run training
config = bonsaiConfig;
BonsaiRunTraining(config, mdl, @episodeStartCallback);

% callback for running model with provided episode configuration
function episodeStartCallback(mdl, episodeConfig)
    in = Simulink.SimulationInput(mdl);
    in = in.setVariable('initToutdoor', episodeConfig.input_Toutdoor);
    in = in.setVariable('n_rooms', episodeConfig.input_nRooms);
    in = in.setVariable('nWindows_room1', episodeConfig.input_nWindowsRoom1);
    
    % Error handle to default values if user does not provide # of windows
    try
        in = in.setVariable('nWindows_room2', episodeConfig.input_nWindowsRoom2);
    catch
        in = in.setVariable('nWindows_room2', 6);
    end
    try
        in = in.setVariable('nWindows_room3', episodeConfig.input_nWindowsRoom3);
    catch
        in = in.setVariable('nWindows_room3', 6);
    end
    
    sim(in);
end
