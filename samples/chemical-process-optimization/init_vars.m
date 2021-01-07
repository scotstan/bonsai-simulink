
%% SET OF CONTROLLER VARIABLES

% Load equilibrium points, used as initial conditions
load('CSTRData.mat')

% Type of control to apply with Bonsai
% Option 1: Per-iteration increment control:  change_per_step_Tc_control = 1
% Option 2: Absolute delta from initial Tc    change_per_step_Tc_control = 2
change_per_step_Tc_control = 2;

% Scenario to be run - 4 scenarios: 1-based INT
% > 1: Concentration transition -->  8.57 to 2.000
% > 2: Concentration transition -->  8.57 to 3.6425
% > 3: Concentration transition -->  8.57 to 5.2850
% > 4: Concentration transition -->  8.57 to 6.9275
j_scenario = 1;

% Percentage of noise to include
noise_magnitude = 0/100;


%% GENERAL SETTINGS

% Sample time used for controller
Ts = 0.5;

% Auxiliary params
conc_noise = (CrEQ(1)-CrEQ(5))*noise_magnitude;
temp_noise = (TrEQ(1)-TrEQ(5))*noise_magnitude;

% Sim starting params (check inside sim on derivative blocks)
%  --> Required for benchmark stretched <--
Cr_sim_ini = 8.57;
Tr_sim_ini = 311.2612;
Tc_sim_ini = 297.9798;
