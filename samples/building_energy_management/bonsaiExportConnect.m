% Script to configure exported Bonsai brain. Exported brains can be
% run in a few steps:
%   1. export your brain
%   2. start exported brain
%   3. configure the endpoint (defaults to localhost:5000)
%   4. run this script to configure an export session and set required variables
%   5. open the model and click "Run"

% load model and disable fast restart
init_vars
mdl = 'buildingEnergyManagement';
load_system(mdl);
set_param(mdl, 'FastRestart', 'off');

% configure exported brain
config = bonsaiConfig;
BonsaiConfigureExportConnect(config, mdl);

% any initial data required for compilation should go here
initToutdoor = 60;