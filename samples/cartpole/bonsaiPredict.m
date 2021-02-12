% Script to configure prediction of your trained Bonsai brain. Prediction can be
% run in 3 steps:
%   1. export your brain
%   2. start exported brain
%   2. configure the endpoint (defaults to localhost:5000)
%   3. run this script to configure a predicting session and set required variables
%   4. open the model and click "Run"

mdl = 'cartpole_discrete';
load_system(mdl);
set_param(mdl, 'FastRestart', 'off');

% run training
config = bonsaiConfig();
BonsaiConfigurePrediction(config, mdl, @episodeConfigCallback);

% any initial data required for compilation should go here
initialPos = 0;

function episodeConfigCallback(mdl, episodeConfig)

end

    