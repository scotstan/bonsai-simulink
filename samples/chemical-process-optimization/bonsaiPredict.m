% Script to configure prediction of your trained Bonsai brain. Prediction can be
% run in a few steps:
%   1. export your brain
%   2. start exported brain
%   3. configure the endpoint (defaults to localhost:5000)
%   4. run this script to configure a predicting session and set required variables
%   5. open the model and click "Run"

% Initial data required for compilation should be initialized
init_vars

% load model and disable fast restart
mdl = 'ChemicalProcessOptimization';
load_system(mdl);
set_param(mdl, 'FastRestart', 'off');

% configure prediction
config = bonsaiConfig;
BonsaiConfigurePrediction(config, mdl, @episodeStartCallback);