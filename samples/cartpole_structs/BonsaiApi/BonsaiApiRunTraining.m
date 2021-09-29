% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Model run loop for training a Bonsai brain

function BonsaiApiRunTraining(config, mdl, episodeStartCallback)
    logger = bonsai.Logger('BonsaiApiRunTraining', config.verbose);

    defaultBrainAction = evalin('base','brainAction');
    bonsaiApi = BonsaiApiClient(mdl, config, defaultBrainAction);
    bonsaiApi.connect(episodeStartCallback);
    
    assignin('base','bonsaiApi',bonsaiApi);
    
    % loop over training
    runException = [];
    try
        
        while ~eq(bonsaiApi.lastEvent, bonsai.EventTypes.Unregister)            
            simState = evalin('base','simState');
            bonsaiApi.getNext(simState); 
        end

    catch runException
        % exception still gets checked below
        disp(runException);
    end

    logger.log('Training loop finished');
end
