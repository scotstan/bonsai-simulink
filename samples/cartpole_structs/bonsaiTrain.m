% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% This sample demonstrates how to create a simulation via MATLAB
% code without using a Simulink model.

% Main entrypoint for training a Bonsai brain. After starting this script you
% must begin training your brain in the web, selecting the "Pure MATLAB"
% simulator.

mdl = 'cartpole_discrete_api';
load_system(mdl);
%set_param(mdl, 'FastRestart', 'on');

%set the default values
fid = fopen('cartpole.json');
raw = fread(fid, inf);
str = char(raw');
initialSimState = jsondecode(str);
simState = initialSimState;

action = 0;
initialPos = 0;
Tmp = get_param(bdroot,'SimulationTime');
Ts = 0;

config = bonsaiConfig;
bonsaiApi = BonsaiApiClient(config);
bonsaiApi.start(initialSimState, @episodeStart, @episodeStep, @getState, @episodeFinish);

% callback for running model with provided episode configuration
function episodeStart(episodeConfig)
    assignin('base','initialPos', episodeConfig.pos);
    set_param(bdroot, 'SimulationCommand', 'Start');
end

% callback for stepping the model with provided action
function episodeStep(lastAction)
    %the action from the brain
    assignin('base','action', lastAction.command);
end

% callback for getting the state from the model
function state = getState()
    
    %the simStateT value comes from the to_workspace block and and is stored as 
    %a time series where we need to access the .data values
    simStateT = evalin('base','simStateT');
    
    %use the helper function to copy the structs
    state = copyFromWorkspace(simStateT);
end

% callback for when an episode finishes
function episodeFinish()
    %cleanup if needed
end

