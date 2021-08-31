% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

function [action,reset] = callBonsaiApi(simState)
    bonsaiApi = evalin('base','bonsaiApi');
    
    reset = false;
    
    if eq(bonsaiApi.lastEvent, bonsai.EventTypes.EpisodeStart) || eq(bonsaiApi.lastEvent, bonsai.EventTypes.EpisodeStep)
        [action,reset] = bonsaiApi.getNext(simState);
    else
        reset = true;
        action = evalin('base','brainAction');
    end
end
    