% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

function config = bonsaiConfig

    config = BonsaiConfiguration();

    % % override api url, defaults to "https://api.bons.ai"
    % config.url = "https://api.bons.ai";
 
    % bonsai workspace
    config.workspace = getenv('SIM_WORKSPACE');

    % access key, generated from https://beta.bons.ai/brains/accounts/settings
    config.accessKey = getenv('SIM_ACCESS_KEY');

    % simulator name, for an unmanaged simulator launched from the desktop to show up on the web
    config.name = "Simulink Chemical Plant";

    % path to bonsai block in your model, used to determine state and action schemas
    %config.bonsaiBlock = "ChemicalProcessOptimization/Bonsai";

    % % set state and action schemas (overrides data from bonsaiBlock)
    config.stateSchema = ["Cr_no_noise", "Tr_no_noise", "Cr", "Tr", "Cref_error", "Tref_error", "Cref", "Tref", "Cref_error_abs_accumulated", "Tref_error_abs_accumulated", "equilibrium", "dTc_abs_accumulated", "dTc_increment", "Tc_delta", "Tc", "C_plan", "T_plan"];
    config.actionSchema = ["Tc_control"];

    % set config schema
    config.configSchema = ["change_per_step_Tc_control", "j_scenario", "noise_percentage"];

    % % time (in seconds) the simulator gateway should wait for
    % %   your simulator to advance, defaults to 60
    % config.timeout = 60;

    % path to csv file where episode data should be logged
    %config.outputCSV = "chemical_plant_training.csv";

    % % display verbose logs
    % config.verbose = false;

end
