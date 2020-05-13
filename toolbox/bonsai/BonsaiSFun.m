% Level-2 S-Function for the bonsai toolbox
% Copyright 2020 Microsoft

function BonsaiSFun(block)
    setup(block);
end

function setup(block)

    % get session instance
    session = bonsai.Session.getInstance();

    % for readability
    DOUBLE_TYPE = 0;
    BOOL_TYPE = 8;

    % set input/output ports
    block.NumInputPorts = 2;
    block.NumOutputPorts = 2;

    % state (Vector<Double>)
    block.InputPort(1).DatatypeID = DOUBLE_TYPE;
    block.InputPort(1).Dimensions = session.config.numStates;
    block.InputPort(1).DirectFeedthrough = false;

    % halted (Bool)
    block.InputPort(2).DatatypeID = BOOL_TYPE;
    block.InputPort(2).Dimensions = 1;
    block.InputPort(2).DirectFeedthrough = false;

    % action (Vector<Double>)
    block.OutputPort(1).DatatypeID = DOUBLE_TYPE;
    block.OutputPort(1).Dimensions = session.config.numActions;
    block.OutputPort(1).SamplingMode = 'Sample';

    % reset (Bool)
    block.OutputPort(2).DatatypeID = BOOL_TYPE;
    block.OutputPort(2).Dimensions = 1;
    block.OutputPort(2).SamplingMode = 'Sample';

    % block takes one parameter for sample time
    block.NumDialogPrms = 1;
    block.SampleTimes = block.DialogPrm(1).Data;
 
    %
    % SetInputPortSamplingMode:
    %   Functionality    : Check and set input and output port 
    %                      attributes and specify whether the port is operating 
    %                      in sample-based or frame-based mode
    %
    block.RegBlockMethod('SetInputPortSamplingMode', @SetInpPortFrameData);

    % for fast restart
    block.OperatingPointCompliance = 'Default';

    %% Register methods called during update diagram/compilation
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Update', @Update);
    block.RegBlockMethod('Outputs', @Outputs);
    block.RegBlockMethod('Terminate', @Terminate);

end

function Start(block)

    % get session instance and logger
    session = bonsai.Session.getInstance();
    logger = bonsai.Logger('BonsaiBlock', session.config.verbose);

    % if no session ID is set, assume sim should register for assessment
    if isempty(session.sessionId)
        logger.verboseLog('No SessionID found, starting a new assessment session...');
        session.startAssessmentSession();
        fig = uifigure;
        message = sprintf('Open the Bonsai Portal to begin assessment on your brain.');
        uialert(fig, message, 'Simulator Registered', 'Icon', 'info');
    else
        logger.verboseLog('Session ID found, assuming sim is registered for training');
    end

end

function Update(block)

    % get session instance and logger
    session = bonsai.Session.getInstance();
    logger = bonsai.Logger('BonsaiBlock', session.config.verbose);

    % get state and halted
    state = block.InputPort(1).Data;
    halted = block.InputPort(2).Data;

    % get next event (unless last event was EpisodeFinish or Unregister)
    if eq(session.lastEvent, bonsai.EventTypes.EpisodeFinish) || ...
        eq(session.lastEvent, bonsai.EventTypes.Unregister)
        logger.log(['Last event was ', session.lastEvent.str, ', done requesting events.']);
    else
        session.getNextEvent(block.CurrentTime, state, halted);
    end

end

function Outputs(block)

    % get session instance
    session = bonsai.Session.getInstance();

    % output action vector, using order actions are listed in the Bonsai block
    fields = fieldnames(session.lastAction);
    if ~isempty(fields)
        block.OutputPort(1).Data = bonsai.Utilities.getStructValuesInOrder(session.lastAction, session.config.actionSchema);
    end

    % signal a reset if last event was episode finish or unregister
    if eq(session.lastEvent, bonsai.EventTypes.EpisodeFinish) || ...
        eq(session.lastEvent, bonsai.EventTypes.Unregister)
        block.OutputPort(2).Data = true;
    else
        block.OutputPort(2).Data = false;
    end

end

function Terminate(block)

        % terminate session if we are in an assessment session
        session = bonsai.Session.getInstance();
        if session.isTrainingSession
            % session will be terminated by BonsaiRunTraining
        else
            session.terminateSession();
        end
end

function SetInpPortFrameData(block, idx, fd)

    block.InputPort(idx).SamplingMode = fd;

end
