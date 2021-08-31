% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

%initialize the buses
initModel;

mdl = 'cartpole_discrete_api_loop';
load_system(mdl);
set_param(mdl, 'FastRestart', 'off');

% other init variables -- in this case, for episode configuration
initialPos = 0;

config = bonsaiConfig;
RunBonsaiTraining(mdl, config, @episodeStart);


% callback for running model with provided episode configuration
function episodeStart(mdl, episodeConfig)

   in = Simulink.SimulationInput(mdl);
   in = in.setVariable('initialPos', episodeConfig.pos);
   sim(in);
      
end


