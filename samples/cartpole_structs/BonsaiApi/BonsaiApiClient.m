% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

classdef BonsaiApiClient < handle

    properties
        sessionId 
        episodeStartCallback
        lastSequenceId 
        lastEvent
    end
    
    properties (Access = private)
        config BonsaiConfiguration
        logger bonsai.Logger
        client bonsai.Client
        defaultAction
        model
    end
  
    methods
        function obj = BonsaiApiClient(mdl,config, emptyBrainAction)
            obj.config = config;
            obj.client = bonsai.Client(config);
            obj.logger = bonsai.Logger('BonsaiApiClient', config.verbose);
            obj.defaultAction = emptyBrainAction;
            obj.lastEvent = bonsai.EventTypes.Registered;
            obj.model = mdl;
        end

        function connect(obj, episodeStartCallback)
            obj.episodeStartCallback = episodeStartCallback;
            r = obj.client.registerSimulator(obj.config.registrationJson());
            obj.lastSequenceId  = 1;
            obj.sessionId = r.sessionId;
            obj.logger.log(['Registered session: ', r.sessionId]);    
        end
        
        function [action,reset] = getNext(obj, simState)
            action = obj.defaultAction;
            reset = false;
            halted = false;
            try
                keepGoing = true;
                while keepGoing
                    
                    requestData = struct('sequenceId', obj.lastSequenceId, ...
                                                'sessionId', obj.sessionId, ...
                                                'halted', halted, ...
                                                'state', simState);
                    data = jsonencode(requestData);

                    obj.logger.log(['getNext, data: ', data]);

                    r = obj.client.getNextEvent(obj.sessionId,data);
                    obj.lastSequenceId = r.sequenceId;
                    obj.lastEvent = bonsai.EventTypes(r.type);
                    
                    switch r.type
                        case bonsai.EventTypes.Idle.str
                            obj.logger.log('Received event: Idle');
                        case bonsai.EventTypes.EpisodeStart.str
                           episodeConfig = r.episodeStart.config;
                           obj.logger.log(['Received event: EpisodeStart, config: ', jsonencode(episodeConfig)]);
                           obj.episodeStartCallback(obj.model, episodeConfig);
                           keepGoing = false;
                        case bonsai.EventTypes.EpisodeStep.str
                            actionString = jsonencode(r.episodeStep.action);
                            obj.logger.log(['Received event: EpisodeStep, actions: ', actionString]);
                            action = r.episodeStep.action;
                            keepGoing = false;
                         case bonsai.EventTypes.EpisodeFinish.str
                            obj.logger.log('Received event: EpisodeFinish');
                            keepGoing = false;
                            reset = true;
                        case bonsai.EventTypes.Unregister.str
                            obj.logger.log('Received event: Unregister');
                            keepGoing = false;
                            reset = true;
                    end
                end
            catch runException
                disp(runException);
            end
        end
    end
end
