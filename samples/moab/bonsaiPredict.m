% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Script to configure prediction of your trained Bonsai brain. Prediction can be
% run in a few steps:
%   1. export your brain
%   2. start exported brain
%   3. configure the endpoint (defaults to localhost:5000)
%   4. run this script to configure a predicting session and set required variables
%   5. open the model and click "Run"

initializeMoab;

% see the visualization
set_param(moab_mdl, 'FastRestart', 'off');

% load model
open_system(moab_mdl);

% configure assessment
config = bonsaiConfig;
BonsaiConfigurePrediction(config, moab_mdl);
