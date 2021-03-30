% Initialization of variables used in the model
excelFile   = 'seEstimatingAssemblyLineThroughput.xlsx';

schedule    = xlsread(excelFile, 'MfgSchedule');
optimes     = xlsread(excelFile, 'OperationTimes');
parameters  = xlsread(excelFile, 'Parameters');

requirements = xlsread(excelFile, 'Requirements');

seed = 12345;                     	% random number seed
scheduleID = 1;
numMfgWorkers = 3;
numInspectWorkers = 3;

schedule = schedule(:, 2);