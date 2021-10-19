% add the BonsaiApi folder to the path
addpath([pwd filesep 'BonsaiApi']);

%the user can choose a script file
if exist('initializeStateAndAction.m','file')
    initializeStateAndAction
%or the state.json and action.json files depending on their preference
elseif exist('state.json','file') && exist('action.json','file')
    fid = fopen('state.json');
    raw = fread(fid, inf);
    str = char(raw');
    simState = jsondecode(str);

    fid = fopen('action.json');
    raw = fread(fid, inf);
    str = char(raw');
    brainAction = jsondecode(str);
else
    ME = MException("FilesNotFound","cannot load initializeStateAndAction.m or state.json and action.json");
    throw ME
end

simStateBus = Simulink.Bus.createObject(simState);
sBusVar = evalin('base',simStateBus.busName);
StateBus = copy(sBusVar);
evalin('base',['clear ' simStateBus.busName])
clear sBusVar simStateBus;

brainActionBus = Simulink.Bus.createObject(brainAction);
aBusVar = evalin('base',brainActionBus.busName);
ActionBus = copy(aBusVar);
evalin('base',['clear ' brainActionBus.busName])
clear aBusVar brainActionBus;