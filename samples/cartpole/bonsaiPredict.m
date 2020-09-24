% Script to configure prediction of your trained Bonsai brain. Prediction can be
% run in 3 steps:
%   1. export your brain
%   2. configure the endpoint
%   3. run this script to configure a predicting session and set required variables
%   4. open the model and click "Run"
%   5. begin assessmnet in the web, selecting the "Simulink Cartpole" simulator.

mdl = 'cartpole_discrete';
load_system(mdl);
set_param(mdl, 'FastRestart', 'off');

% run training
config = bonsaiConfig(true);
BonsaiConfigurePrediction(config, mdl, @episodeConfigCallback);

function episodeConfigCallback(mdl, episodeConfig)

end

    