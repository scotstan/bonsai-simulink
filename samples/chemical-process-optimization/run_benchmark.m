%% Run the sample without toolboxes
clear;
close all;
clc;

%% Initialize Workspace 

% Load equilibrium points, used as initial conditions
load('CSTRData.mat')
% Initialize model params (reused for bonsai training)
init_vars

% Sample time used for controller
Ts = 0.5;

% Residual Concentration Range
Cr_vec = [2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9];

open_system('ChemicalProcessOptimization')

% This writes to the Default Signal builder (j_scenario = 1)
target_t = [0; 10; 36; 45];
target_Cr = [8.57; 8.57; 2; 2]; 
signalbuilder('ChemicalProcessOptimization/Target concentration', 'set', 'Signal 1', 'Group 1', target_t, target_Cr);
%% Using Constant Gains (No Lookup)

% PI Controller
Kp_vec = ones(1, length(Cr_vec)) * -2.00046148741648;
Ki_vec = ones(1, length(Cr_vec)) * -7.98512854300473;

% Lead Controller
Kt_vec = ones(1, length(Cr_vec)) * 3.60620000481947;
a_vec = ones(1, length(Cr_vec)) * 0.384207621232031;
b_vec = ones(1, length(Cr_vec)) * 0.0628087670628903;

sim('ChemicalProcessOptimization')
% Calculate metrics
metric_rms = sqrt(mean((simout(:, 1) - simout(:, 2)).^2));
disp(['Constant Gains: Target Concentration followed with RMS of: ', num2str(metric_rms)])

metric_rms = sqrt(mean((simout(:, 3) - simout(:, 4)).^2));
disp(['Constant Gains: Target Reactor Temperature followed with RMS of: ', num2str(metric_rms)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

plot_results(tout, simout)

%% Benchmark
% To prevent thermal runaway while ramping down the residual concentration,
% use feedback control to adjust the coolant temperature |Tc| based on
% measurements of the residual concentration |Cr| and reactor temperature |Tr|.
% For this application, we use a cascade control architecture where
% the inner loop regulates the reactor temperature and the outer loop tracks
% the concentration setpoint. Both feedback loops are digital with a 
% sampling period of 0.5 minutes.

% PI Controller
Kp_vec = [-2.00046148741648;-2.3184560846763;-2.65393524901532;-3.00689898043353;-3.37734727893094;-3.76528014450754;-4.17069757716334;-4.59359957689834;-5.03398614371254;-5.49185727760593;-5.96721297857851;-6.4600532466303;-6.97037808176128;-7.49818748397146;-8.04348145326083];
Ki_vec = [-7.98512854300473;-6.23612330817463;-4.75246287755465;-3.53414725114479;-2.58117642894504;-1.8935504109554;-1.47126919717588;-1.31433278760647;-1.42274118224718;-1.796494381098;-2.43559238415893;-3.34003519142998;-4.50982280291114;-5.94495521860242;-7.64543243850381];

% Lead Controller
Kt_vec = [3.60620000481947;3.57285570622906;3.55992955218359;3.56742154268306;3.59533167772747;3.64365995731683;3.71240638145112;3.80157095013036;3.91115366335453;4.04115452112365;4.19157352343771;4.36241067029671;4.55366596170065;4.76533939764953;4.99743097814336];
a_vec = [0.384207621232031;0.492686723524811;0.580956543031792;0.649017079752974;0.696868333688357;0.72451030483794;0.731942993201725;0.71916639877971;0.686180521571896;0.632985361578283;0.55958091879887;0.465967193233659;0.352144184882648;0.218111893745838;0.0638703198232284];
b_vec = [0.0628087670628903;0.0875474545057933;0.110088960048547;0.130433283691153;0.148580425433609;0.164530385275917;0.178283163218075;0.189838759260085;0.199197173401946;0.206358405643658;0.211322455985221;0.214089324426636;0.214659010967901;0.213031515609018;0.209206838349985];

sim('ChemicalProcessOptimization')

% Calculate metrics
metric_rms = sqrt(mean((simout(:, 1) - simout(:, 2)).^2));
disp(['Benchmark: Target Concentration followed with RMS of: ', num2str(metric_rms)])

metric_rms = sqrt(mean((simout(:, 3) - simout(:, 4)).^2));
disp(['Benchmark: Target Reactor Temperature followed with RMS of: ', num2str(metric_rms)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

plot_results(tout, simout)

%% Benchmark (stretch - 1% noise)

% Percentage of noise to include
noise_magnitude = 1/100;
% Auxiliary params
conc_noise = (CrEQ(1)-CrEQ(5))*noise_magnitude;
temp_noise = (TrEQ(1)-TrEQ(5))*noise_magnitude;

sim('ChemicalProcessOptimization')

% Calculate metrics
metric_rms = sqrt(mean((simout(:, 1) - simout(:, 2)).^2));
disp(['Strech Benchmark (noise): Target Concentration followed with RMS of: ', num2str(metric_rms)])

metric_rms = sqrt(mean((simout(:, 3) - simout(:, 4)).^2));
disp(['Strech Benchmark (1% noise): Target Reactor Temperature followed with RMS of: ', num2str(metric_rms)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

plot_results(tout, simout)


%% Benchmark (stretch -  target Cr of 1)

% get rid of noise
init_vars

% Change the target concentration ranges, extrapolating from gain schedule
target_Cr = [8.57; 8.57; 1; 1];
signalbuilder('ChemicalProcessOptimization/Target concentration', 'set', 'Signal 1', 'Group 1', target_t, target_Cr);

sim('ChemicalProcessOptimization')

% Calculate metrics
metric_rms = sqrt(mean((simout(:, 1) - simout(:, 2)).^2));
disp(['Strech Benchmark (Cr of 1): Target Concentration followed with RMS of: ', num2str(metric_rms)])

metric_rms = sqrt(mean((simout(:, 3) - simout(:, 4)).^2));
disp(['Strech Benchmark (Cr of 1): Target Reactor Temperature followed with RMS of: ', num2str(metric_rms)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

plot_results(tout, simout)

%% Initialize Default Variables to avoid issues with Bonsai training
% i.e. signal builder
% no noise, etc
init_vars

% This writes to the Default Signal builder (j_scenario = 1)
target_t = [0; 10; 36; 45];
target_Cr = [8.57; 8.57; 2; 2]; 
signalbuilder('ChemicalProcessOptimization/Target concentration', 'set', 'Signal 1', 'Group 1', target_t, target_Cr);


%% Functions 

function [] = plot_results(tout, simout)
    figure
    subplot(311)
    plot(tout, simout(:, 1))
    hold on
    plot(tout, simout(:, 2))
    hold off
    legend('Ref', 'Actual')
    grid, title('Residual concentration'), ylabel('Cr')

    subplot(312)
    plot(tout, simout(:, 3))
    hold on
    plot(tout, simout(:, 4))
    hold off
    legend('Ref', 'Actual')
    grid, title('Reactor temperature'), ylabel('Tr')

    subplot(313)
    plot(tout, simout(:, 5))
    hold on
    plot(tout, simout(:, 6))
    hold off
    legend('Raw', 'Saturated')
    grid, title('Coolant temperature'), ylabel('dTc')
end
