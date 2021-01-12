% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Main entrypoint for training a Bonsai brain. After starting this script you
% must begin training your brain in the web, selecting the "Simulink Chemical Plant"
% simulator.

init_vars

% load model and enable fast restart
mdl = 'ChemicalProcessOptimization';
load_system(mdl);
set_param(mdl, 'FastRestart', 'on');

% run training
config = bonsaiConfig;
BonsaiRunTraining(config, mdl, @episodeStartCallback);

% callback for running model with provided episode configuration
function episodeStartCallback(mdl, episodeConfig)
    in = Simulink.SimulationInput(mdl);
    in = in.setVariable('Cref_signal', episodeConfig.Cref_signal);
    noise_magnitude = episodeConfig.noise_percentage/100;
    in = in.setVariable('temp_noise', (TrEQ(1)-TrEQ(5))*noise_magnitude);
    in = in.setVariable('conc_noise', (CrEQ(1)-CrEQ(5))*noise_magnitude);
    sim(in);
end
