% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% function to configure assessment of a Bonsai brain

function BonsaiApiConfigureAssessment(config, mdl, episodeStartCallback)

    % configure api
    defaultBrainAction = evalin('base','brainAction');
    bonsaiApi = BonsaiApiClient(mdl, config, defaultBrainAction);
    bonsaiApi.connect(episodeStartCallback);
    
    %start the loop
    simState = evalin('base','simState');
    bonsaiApi.getNext(simState);
    
    assignin('base','bonsaiApi',bonsaiApi);

    % print success
    logger = bonsai.Logger('BonsaiApiConfigureAssessment', config.verbose);
    logger.log('Configuration for assessment complete.');

end

