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
    config.name = "Simulink - Job Scheduling";

    % path to bonsai block in your model, used to determine state and action schemas
%     config.bonsaiBlock = "seEstimatingAssemblyLineThroughput/Bonsai";

    % % set state and action schemas (overrides data from bonsaiBlock)
    config.stateSchema = ["num_bad_parts", "num_good_parts", "numMfgWorkersUsed", ...
                          "numInspectWorkersUsed" ...
                          ];
    config.actionSchema = ["product_variant_order"];

    % set config schema
    config.configSchema = ["discard_rate", "numMfgWorkers", "numInspectWorkers"];

    % % time (in seconds) the simulator gateway should wait for
    % %   your simulator to advance, defaults to 60
    config.timeout = 60;

    % path to csv file where episode data should be logged
%     config.outputCSV = "job_scheduling.csv";

    % % display verbose logs
    config.verbose = false;

end
