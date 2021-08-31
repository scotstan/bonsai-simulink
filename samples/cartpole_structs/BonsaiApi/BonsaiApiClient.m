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
        defaultAction
        model
    end
  
    methods
        function obj = BonsaiApiClient(mdl,config, emptyBrainAction)
            obj.config = config;
            obj.logger = bonsai.Logger('BonsaiApiClient', config.verbose);
            obj.defaultAction = emptyBrainAction;
            obj.lastEvent = bonsai.EventTypes.Registered;
            obj.model = mdl;
        end

        function r = makeRequest(obj, data, method, endpoint)
            urlString = strcat(obj.config.url, '/v2/workspaces/', ...
                               obj.config.workspace, endpoint);
            requestUrl = matlab.net.URI(urlString);

            options = weboptions('HeaderFields', {'Authorization', obj.config.accessKey}, ...
                                 'CharacterEncoding', 'UTF-8', ...
                                 'ContentType', 'json', ...
                                 'MediaType', 'application/json', ...
                                 'RequestMethod', method, ...
                                 'Timeout', 90);

            obj.logger.verboseLog(char(strcat("Sending API ", method, " to ", urlString, ":")));
            obj.logger.verboseLog(data);
            r = webwrite(requestUrl, data, options);
            obj.logger.verboseLog('Response:');
            obj.logger.verboseLog(jsonencode(r));
        end

        function r = attemptRequest(obj, data, method, endpoint)
            attempt = 0;
            maxAttempts = 50;
            success = false;
            while ~success && attempt < maxAttempts
                try
                    r = obj.makeRequest(data, method, endpoint);
                    success = true;
                catch e
                    statusTimeout = 'MATLAB:webservices:Timeout';
                    status401 = 'MATLAB:webservices:HTTP401StatusCodeError';
                    status403 = 'MATLAB:webservices:HTTP403StatusCodeError';
                    status404 = 'MATLAB:webservices:HTTP404StatusCodeError';
                    status502 = 'MATLAB:webservices:HTTP502StatusCodeError';
                    status503 = 'MATLAB:webservices:HTTP503StatusCodeError';
                    status504 = 'MATLAB:webservices:HTTP504StatusCodeError';

                    if (strcmp(e.identifier, status401) || strcmp(e.identifier, status403))
                        msg = ['Bonsai API "', method, ...
                            '" returned status code ', e.identifier, ...
                            '. Check that your workspace and access key are correct.'];
                        throw(MException('Bonsai:Exception', msg));
                    elseif (strcmp(e.identifier, status404))
                        msg = ['Bonsai API "', method, ...
                            '" returned status code 404:\n', e.message];
                        throw(MException('Bonsai:Exception', msg));
                    elseif (strcmp(e.identifier, statusTimeout))
                        msg = ['Bonsai API took too long to respond:\n', e.message];
                        throw(MException('Bonsai:Exception', msg));
                    elseif (strcmp(e.identifier, status502) || ...
                            strcmp(e.identifier, status503) || ...
                            strcmp(e.identifier, status504))
                        obj.logger.log('Request received a 502/503/504 response, retrying...');
                        obj.logger.log(e);
                    else
                        obj.logger.log('Request generated un-handled error:');
                        obj.logger.log(e);
                        rethrow(e);
                    end
                    attempt = attempt + 1;
                    pause(1);
                end
            end

            if attempt >= maxAttempts
                error(['Request failed after ', num2str(maxAttempts), ' retries.']);
            end
        end

        function r = registerSimulator(obj, data)
            r = obj.attemptRequest(data, 'post', '/simulatorSessions');
        end

        function r = deleteSimulator(obj, sessionId)
            endpoint = strcat('/simulatorSessions/', sessionId);
            r = obj.attemptRequest('', 'delete', endpoint);
        end

        function r = getNextEvent(obj, sessionId, data)
            endpoint = strcat('/simulatorSessions/', sessionId, '/advance');
            r = obj.attemptRequest(data, 'post', endpoint);
        end

        %{
        function start(obj, initialSimState, episodeStartCallback, episodeStepCallback, getStateCallback, episodeFinishCallback)
            r = obj.registerSimulator(obj.config.registrationJson());
            obj.sessionId = r.sessionId;
            obj.logger.log(['Registered session: ', r.sessionId]);
            
            halted = false;
            lastSequenceId = 1;
            simState = initialSimState;
            lastEvent = bonsai.EventTypes.Registered;
            lastAction = struct();
            episodeConfig = struct();
            
            try
                keepGoing = true;
                while keepGoing
                    %keepGoing = session.startNewEpisode();

                    requestData = struct('sequenceId', lastSequenceId, ...
                                                'sessionId', obj.sessionId, ...
                                                'halted', halted, ...
                                                'state', simState);
                    data = jsonencode(requestData);

                    r = obj.getNextEvent(obj.sessionId,data);
                    lastSequenceId = r.sequenceId;
                    lastEvent = bonsai.EventTypes(r.type);

                    switch r.type
                        case bonsai.EventTypes.Idle.str
                            obj.logger.log('Received event: Idle');
                        case bonsai.EventTypes.EpisodeStart.str
                           episodeConfig = r.episodeStart.config;
                           episodeStartCallback(episodeConfig); 
                        case bonsai.EventTypes.EpisodeStep.str
                            actionString = jsonencode(r.episodeStep.action);
                            obj.logger.log(['Received event: EpisodeStep, actions: ', actionString]);
                            lastAction = r.episodeStep.action;

                            episodeStepCallback(lastAction);
                            
                            %step the model
                            set_param(bdroot, 'SimulationCommand','continue');

                            %update the state
                            simState = getStateCallback(); 

                            %pause the model and wait for the next action
                            %set_param(bdroot, 'SimulationCommand','pause');
                         case bonsai.EventTypes.EpisodeFinish.str
                            obj.logger.log('Received event: EpisodeFinish');
                            set_param(bdroot, 'SimulationCommand', 'Stop');
                            % reset action and config
                            lastAction = struct();
                            simState = initialSimState;
                            episodeConfig = struct();
                            episodeFinishCallback();
                        case bonsai.EventTypes.Unregister.str
                            obj.logger.log('Received event: Unregister');
                            % reset action and config
                            lastAction = struct();
                            episodeConfig = struct(); 
                            keepGoing = false;
                    end
                end
            catch runException
                % exception still gets checked below
                disp(runException);
            end
        end
        %} 

        function connect(obj, episodeStartCallback)
            obj.episodeStartCallback = episodeStartCallback;
            r = obj.registerSimulator(obj.config.registrationJson());
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

                    r = obj.getNextEvent(obj.sessionId,data);
                    obj.lastSequenceId = r.sequenceId;
                    obj.lastEvent = bonsai.EventTypes(r.type);
                    
                    switch r.type
                        case bonsai.EventTypes.Idle.str
                            obj.logger.log('Received event: Idle');
                        case bonsai.EventTypes.EpisodeStart.str
                           episodeConfig = r.episodeStart.config;
                           obj.logger.log(['Received event: EpisodeStart, config: ', jsonencode(episodeConfig)]);
                           obj.episodeStartCallback(obj.model, episodeConfig);
                           %set_param(obj.model, 'SimulationCommand','Start');
                           keepGoing = false;
                        case bonsai.EventTypes.EpisodeStep.str
                            actionString = jsonencode(r.episodeStep.action);
                            obj.logger.log(['Received event: EpisodeStep, actions: ', actionString]);
                            action = r.episodeStep.action;
                            keepGoing = false;
                         case bonsai.EventTypes.EpisodeFinish.str
                            obj.logger.log('Received event: EpisodeFinish');
                            keepGoing = false;
                            %obj.episodeFinishCallback();
                            reset = true;
                            %set_param(obj.model, 'SimulationCommand','Stop');
                        case bonsai.EventTypes.Unregister.str
                            obj.logger.log('Received event: Unregister');
                            keepGoing = false;
                            reset = true;
                    end
                end
            catch runException
                % exception still gets checked below
                disp(runException);
            end
            
            
            %assignin('base','bonsaiApi',obj);
        end
    end
end
