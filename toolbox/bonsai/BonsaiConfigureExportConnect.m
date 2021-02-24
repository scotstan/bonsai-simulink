% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% function to configure connecting to an exported Bonsai brain

function BonsaiConfigureExportConnect(config, mdl)

    config.export = true;
    
    % configure session
    session = bonsai.Session.getInstance();
    session.configure(config, mdl, @undefinedCallback, false);

    % print success
    logger = bonsai.Logger('BonsaiConfigureExportConnect', config.verbose);
    logger.log('Configuration for connecting to exported brain complete.');

end
