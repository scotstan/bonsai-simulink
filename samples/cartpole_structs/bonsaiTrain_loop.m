% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% This sample demonstrates how to create a simulation via MATLAB
% code without using a Simulink model.

% Main entrypoint for training a Bonsai brain. After starting this script you
% must begin training your brain in the web, selecting the "Pure MATLAB"
% simulator.

initModel;

mdl = 'cartpole_discrete_api_loop';
load_system(mdl);
set_param(mdl, 'FastRestart', 'off');

config = bonsaiConfig;
RunBonsaiTraining(mdl, config, @episodeStart);


% callback for running model with provided episode configuration
function episodeStart(mdl, episodeConfig)

   in = Simulink.SimulationInput(mdl);
   in = in.setVariable('initialPos', episodeConfig.pos)
   sim(in);
      
end


