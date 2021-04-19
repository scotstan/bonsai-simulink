% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% This sample demonstrates how to create a simulation via MATLAB
% code without using a Simulink model.

% Main entrypoint for training a Bonsai brain. After starting this script you
% must begin training your brain in the web, selecting the "Pure MATLAB"
% simulator.

global simulation
simulation = Simulation;

% run training
config = bonsaiConfig;
BonsaiRunTraining(config, 'NonSimulinkModel', @episodeStartCallback);

% callback for running model with provided episode configuration
function episodeStartCallback(~, episodeConfig)
    global simulation
    simulation.reset(episodeConfig);
    
    session = bonsai.Session.getInstance();
    logger = bonsai.Logger('bonsaiTrain', session.config.verbose);
    
    logger.log('Starting pure MATLAB Episode');
    
    iteration = 0;
    halted = false;
    while true
        iteration = iteration + 1;
        session.getNextEvent(iteration, simulation.getState(), halted);
        if session.lastEvent ~= bonsai.EventTypes.EpisodeStep
            return
        end
        halted = simulation.step(session.lastAction);
    end
end
