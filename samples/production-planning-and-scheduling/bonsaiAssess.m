% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Script to configure assessment of your trained Bonsai brain. Assessment can be
% run in 3 steps:
%   1. run this script to configure an assessment session and set required variables
%   2. open the model and click "Run"
%   3. begin assessmnet in the web, selecting the "Simulink Chemical Plant" simulator.

% Initial data required for compilation should be initialized
init_vars

% load model and disable fast restart
mdl = 'ChemicalProcessOptimization';
load_system(mdl);
set_param(mdl, 'FastRestart', 'off');

% configure assessment
config = bonsaiConfig;
BonsaiConfigureAssessment(config, mdl, @episodeStartCallback);


% callback for provided episode configuration
function episodeStartCallback(mdl, episodeConfig)
    assignin('base', 'discard_rate', episodeConfig.discard_rate);
    assignin('base', 'numMfgWorkers', episodeConfig.numMfgWorkers);
    assignin('base', 'numInspectWorkers', episodeConfig.numInspectWorkers);
end
