% add the BonsaiApi folder to the path
addpath([pwd filesep 'BonsaiApi']);

%%%%%%%%
% STATE 
%
% use the state.json file to define the simState struct, which creates the StateBus used in Simulink 
%
%%%%%%%%
fid = fopen('state.json');
raw = fread(fid, inf);
str = char(raw');
simState = jsondecode(str);

simStateBus = Simulink.Bus.createObject(simState);
sBusVar = evalin('base',simStateBus.busName);
StateBus = copy(sBusVar);
evalin('base',['clear ' simStateBus.busName])
clear sBusVar simStateBus;


%%%%%%%%
% ACTION 
%
% use the action.json file to define the brainAction struct, which creates the ActionBus used in Simulink 
%
%%%%%%%%
fid = fopen('action.json');
raw = fread(fid, inf);
str = char(raw');
brainAction = jsondecode(str);

brainActionBus = Simulink.Bus.createObject(brainAction);
aBusVar = evalin('base',brainActionBus.busName);
ActionBus = copy(aBusVar);
evalin('base',['clear ' brainActionBus.busName])
clear aBusVar brainActionBus;
 
% other init variables -- in this case, for episode configuration
initialPos = 0;