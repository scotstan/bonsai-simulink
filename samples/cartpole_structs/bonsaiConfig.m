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
    config.name = "Simulink Cartpole";

   
    % % time (in seconds) the simulator gateway should wait for
    % %   your simulator to advance, defaults to 60
    % config.timeout = 60;

    % path to csv file where episode data should be logged
    % config.outputCSV = "cartpole-training.csv"; --> TODO: Handle the
    % output differently

    % % display verbose logs
    % config.verbose = true;

    % Set exported brain url. Defaults to localhost:5000
    % config.exportedBrainUrl = '<your exported brain url>';

end
