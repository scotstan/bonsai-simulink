% Script to configure assessment of your trained Bonsai brain. Assessment can be
% run in 3 steps:
%   1. run this script to configure an assessment session and set required variables
%   2. open the model and click "Run"
%   3. begin assessmnet in the web, selecting the "Simulink Cartpole" simulator.

% load model
mdl = 'cartpole_discrete_no_animation';
load_system(mdl);

% configure assessment
config = bonsaiConfig;
BonsaiConfigureAssessment(config, mdl, @episodeStartCallback);

% any initial data required for compilation should go here
initialPos = 0;

% callback for provided episode configuration
function episodeStartCallback(mdl, episodeConfig)
    assignin('base', 'initialPos', episodeConfig.pos);
end
