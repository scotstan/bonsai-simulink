% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% function to configure prediction of a Bonsai brain

function BonsaiConfigurePrediction(config, mdl)

    config.predict = true;
    
    % configure session
    session = bonsai.Session.getInstance();
    session.configure(config, mdl, @undefinedCallback, false);

    % print success
    logger = bonsai.Logger('BonsaiConfigurePrediction', config.verbose);
    logger.log('Configuration for prediction complete.');

end
