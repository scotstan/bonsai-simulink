% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

function config = bonsaiConfig

    config = BonsaiConfiguration();

    % % override api url, defaults to "https://api.bons.ai"
    % config.url = "https://api.bons.ai";
 
    % bonsai workspace ID, see https://preview.bons.ai/accounts/settings
    config.workspace = "<your workspace here>";

    % access key, generated from https://preview.bons.ai/accounts/settings
    config.accessKey = "<your access key here>";

    % simulator name, for an unmanaged simulator launched from the desktop to show up on the web
    config.name = "Simulink - Chemical Process";

    % path to bonsai block in your model, used to determine state and action schemas
    %config.bonsaiBlock = "ChemicalProcessOptimization/Bonsai";

    % % set state and action schemas (overrides data from bonsaiBlock)
    config.stateSchema = ["Cr", "Tr", "Cr_no_noise", "Tr_no_noise", ...
                          "Cref", "Tref", "dTc", "dTc_rate_limited", ...
                          "Tc", "Tc_eq", "dTc_prev"];
    config.actionSchema = ["Tc_adjust"];

    % set config schema
    config.configSchema = ["Cref_signal", "noise_percentage"];

    % % time (in seconds) the simulator gateway should wait for
    % %   your simulator to advance, defaults to 60
    config.timeout = 60;

    % path to csv file where episode data should be logged
    %config.outputCSV = "chemical_plant_training.csv";

    % % display verbose logs
    config.verbose = false;

end
