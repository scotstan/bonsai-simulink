
%% SET OF CONTROLLER VARIABLES

% Load equilibrium points, used as initial conditions
load('CSTRData.mat')

% Scenario to be run - 4 scenarios: 1-based INT
% > 1: Concentration transition -->  8.57 to 2.000 over [0, 10, 36, 45]
% > 2: Concentration transition -->  8.57 to 2.000 over [0, 2, 28, 45]
% > 3: Concentration transition -->  8.57 to 2.000 over [0, 10, 20, 45]
% > 4: Concentration transition -->  8.57 to 1.000 over [0, 10, 36, 45]

Cref_signal = 1;

% Percentage of noise to include
noise_magnitude = 0/100;

%% GENERAL SETTINGS

% Sample time used for controller
Ts = 0.5;

% Auxiliary params
conc_noise = abs(CrEQ(1)-CrEQ(5))*noise_magnitude;
temp_noise = abs(TrEQ(1)-TrEQ(5))*noise_magnitude;