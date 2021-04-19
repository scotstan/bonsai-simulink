% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

function config = bonsaiConfig

    config = BonsaiConfiguration();

    % % override api url, defaults to "https://api.bons.ai"
    % config.url = "https://api.bons.ai";

    % bonsai workspace ID, see https://preview.bons.ai/accounts/settings
    config.workspace = "<your workspace ID here>";

    % access key, generated from https://preview.bons.ai/accounts/settings
    config.accessKey = "<your access key here>";

    % simulator name, for an unmanaged simulator launched from the desktop to show up on the web
    config.name = "Pure MATLAB";

    % path to bonsai block in your model, used to determine state and action schemas
    config.bonsaiBlock = "cartpole_discrete/Bonsai";

    % % set state and action schemas (overrides data from bonsaiBlock)
    config.stateSchema = ["observation1", "observation2", "sim_reward"];
    config.actionSchema = ["array_action1", "array_action2"];

    % set config schema
    config.configSchema = ["config_array3"];

    % % time (in seconds) the simulator gateway should wait for
    % %   your simulator to advance, defaults to 60
    % config.timeout = 60;

    % path to csv file where episode data should be logged
    % CSVWriter fails if state contains arrays.
    config.outputCSV = '';

    % % display verbose logs
    % config.verbose = true;

    % Set exported brain url. Defaults to localhost:5000
    % config.exportedBrainUrl = '<your exported brain url>';

end
