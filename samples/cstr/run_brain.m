%% Run the sample with brain
%clear;
%close all;
clc;

%config.exportedBrainUrl = 'http://localhost:5004/v1/prediction'; %Brain trained with 10% noise, Signal 1
%% Initialize Workspace 

% Initialize model params (reused for bonsai training)
init_vars
%exportedBrainUrl = 'http://localhost:5005/v1/prediction'; 
% Residual Concentration Range
Cr_vec = [2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9];

open_system('ChemicalProcessOptimization_Bonsai')
set_param('ChemicalProcessOptimization/Variant Subsystem', 'VChoice', 'Bonsai')
% This writes to the Default Signal builder (Cref_signal = 1)
% target_t = [0; 0; 26; 45];
% target_Cr = [8.57; 8.57; 2; 2]; 
% signalbuilder('ChemicalProcessOptimization/Target concentration', 'set', 'Signal 1', 'Group 1', target_t, target_Cr);

Cref_signal=5;

%% Brain (0% noise)

%blockparameters

sim('ChemicalProcessOptimization');
tout_0_b = tout;
simout_0_b = simout;

% Calculate metrics
metric_rms_C_brain = sqrt(mean((simout_0_b(:, 1) - simout_0_b(:, 2)).^2));
disp(['Brain: Target Concentration followed with RMS of: ', num2str(metric_rms_C_brain)])

metric_rms_T_brain = sqrt(mean((simout_0_b(:, 3) - simout_0_b(:, 4)).^2));
disp(['Brain: Target Reactor Temperature followed with RMS of: ', num2str(metric_rms_T_brain)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

% title = 'test';
% plot_results(tout, simout,title)

%% Benchmark (with 5% noise)

% Percentage of noise to include
noise_magnitude = 5/100;
% Auxiliary params
conc_noise = abs(CrEQ(1)-CrEQ(5))*noise_magnitude;
temp_noise = abs(TrEQ(1)-TrEQ(5))*noise_magnitude;

sim('ChemicalProcessOptimization_Bonsai');
tout_5_b = tout;
simout_5_b = simout;

% Calculate metrics
metric_rms = sqrt(mean((simout_5_b(:, 1) - simout_5_b(:, 2)).^2));
disp(['Brain (5% noise): Target Concentration followed with RMS of: ', num2str(metric_rms)])
metric_rms_C_brain_5 = metric_rms;

metric_rms = sqrt(mean((simout_5_b(:, 3) - simout_5_b(:, 4)).^2));
disp(['Brain (5% noise): Target Reactor Temperature followed with RMS of: ', num2str(metric_rms)])
disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
metric_rms_T_brain_5 = metric_rms;

% plot_results(tout, simout_5_b, title)

%% Benchmark (with 10% noise)

% % Percentage of noise to include
% noise_magnitude = 10/100;
% % Auxiliary params
% conc_noise = abs(CrEQ(1)-CrEQ(5))*noise_magnitude;
% temp_noise = abs(TrEQ(1)-TrEQ(5))*noise_magnitude;
% 
% sim('ChemicalProcessOptimization');
% tout_10_b = tout;
% simout_10_b = simout;
% 
% % Calculate metrics
% metric_rms = sqrt(mean((simout_10_b(:, 1) - simout_10_b(:, 2)).^2));
% disp(['Brain (10% noise): Target Concentration followed with RMS of: ', num2str(metric_rms)])
% metric_rms_C_brain_10 = metric_rms;
% 
% metric_rms = sqrt(mean((simout_10_b(:, 3) - simout_10_b(:, 4)).^2));
% disp(['Brain (10% noise): Target Reactor Temperature followed with RMS of: ', num2str(metric_rms)])
% disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
% metric_rms_C_brain_10 = metric_rms;

%% Plot

plot_all_results(tout_0_b, simout_0_b,tout_5_b, simout_5_b)
% plot_all_results(tout_0_b, simout_0_b,tout_5_b, simout_5_b,tout_10_b, simout_10_b)


%% Plot RMS

load benchmarkRMS.mat

x = categorical({'Concentration RMS', 'Temp RMS'});
x = reordercats(x, {'Concentration RMS', 'Temp RMS'});
y = [metric_rms_C_bench metric_rms_C_brain; 
     metric_rms_T_bench metric_rms_C_brain];
 
x5 = categorical({ 'Concentration RMS - 5% noise', 'Temp RMS - 5% nosie'});
x5 = reordercats(x5, {'Concentration RMS - 5% noise', 'Temp RMS - 5% nosie'});
y5 = [metric_rms_C_bench_5 metric_rms_C_brain_5;
     metric_rms_T_bench_5 metric_rms_T_brain_5];
 
 
% x5 = categorical({'Concentration RMS - 0% noise', 'Temp RMS - 0% noise', 'Concentration RMS - 5% noise', 'Temp RMS - 5% nosie'});
% x5 = reordercats(x5, {'Concentration RMS - 0% noise', 'Temp RMS - 0% noise', 'Concentration RMS - 5% noise', 'Temp RMS - 5% nosie'});
% y5 = [metric_rms_C_bench metric_rms_C_brain; 
%      metric_rms_T_bench metric_rms_C_brain; 
%      metric_rms_C_bench_5 metric_rms_C_brain_5;
%      metric_rms_T_bench_5 metric_rms_T_brain_5];
%  
 figure
 subplot(121)
 bar(x,y)
 title('Error - 0% noise simulated'),
 ylabel('RMS of error'),
 legend('Benchmark','Brain')
 
 subplot(122)
 bar(x5,y5)
 title('Error - 5% noise simulated')
 legend('Benchmark','Brain')

%% Initialize Default Variables to avoid issues with Bonsai training
% i.e. signal builder
% no noise, etc
init_vars

% This writes to the Default Signal builder (Cref_signal = 1)
target_t = [0; 10; 36; 45];
target_Cr = [8.57; 8.57; 2; 2]; 
signalbuilder('ChemicalProcessOptimization/Target concentration', 'set', 'Signal 1', 'Group 1', target_t, target_Cr);


%% Functions 

function [] = plot_results(tout, simout, title)
    figure
    subplot(311)
    plot(tout, simout(:, 1))
    hold on
    plot(tout, simout(:, 2))
    hold off
    legend('Ref', 'Actual')
    grid, title('Residual concentration', title), ylabel('Cr')

    subplot(312)
    plot(tout, simout(:, 3))
    hold on
    plot(tout, simout(:, 4))
    hold off
    legend('Ref', 'Actual')
    grid, title('Reactor temperature'), ylabel('Tr')

%     subplot(313)
%     plot(tout, simout(:, 5))
%     hold on
%     plot(tout, simout(:, 6))
%     hold off
%     legend('Raw', 'Saturated')
%     grid, title('Coolant temperature'), ylabel('dTc')
end

function [] = plot_all_results(tout_0_b, simout_0_b,tout_5_b, simout_5_b)
    figure
    subplot(221)
    plot(tout_0_b, simout_0_b(:, 1))
    hold on
    plot(tout_0_b, simout_0_b(:, 2))
    hold off
    legend('Ref', 'Actual')
    grid, title('0% noise simulated'), ylabel('Residual Concentration (Cr)')

    subplot(223)
    plot(tout_0_b, simout_0_b(:, 3))
    hold on
    plot(tout_0_b, simout_0_b(:, 4))
    hold off
    legend('Ref', 'Actual')
    grid, ylabel('Reactor Temperature (Tr)'), xlabel ('time (s)')
    
    subplot(222)
    plot(tout_5_b, simout_5_b(:, 1))
    hold on
    plot(tout_5_b, simout_5_b(:, 2))
    hold off
    legend('Ref', 'Actual')
    grid, title('5% noise simulated'), ylabel('Residual Concentration (Cr)')

    subplot(224)
    plot(tout_5_b, simout_5_b(:, 3))
    hold on
    plot(tout_5_b, simout_5_b(:, 4))
    hold off
    legend('Ref', 'Actual')
    grid, ylabel('Reactor Temperature (Tr)'), xlabel ('time (s)')
    
    
    sgtitle('Brain trained with 5% noise')
end

% function [] = plot_all_results(tout_0_b, simout_0_b,tout_5_b, simout_5_b,tout_10_b, simout_10_b)
%     figure
%     subplot(231)
%     plot(tout_0_b, simout_0_b(:, 1))
%     hold on
%     plot(tout_0_b, simout_0_b(:, 2))
%     hold off
%     legend('Ref', 'Actual')
%     grid, title('0% noise simulated'), ylabel('Residual Concentration (Cr)')
% 
%     subplot(234)
%     plot(tout_0_b, simout_0_b(:, 3))
%     hold on
%     plot(tout_0_b, simout_0_b(:, 4))
%     hold off
%     legend('Ref', 'Actual')
%     grid, ylabel('Reactor Temperature (Tr)'), xlabel ('time (s)')
%     
%     subplot(232)
%     plot(tout_5_b, simout_5_b(:, 1))
%     hold on
%     plot(tout_5_b, simout_5_b(:, 2))
%     hold off
%     legend('Ref', 'Actual')
%     grid, title('5% noise simulated'), ylabel('Residual Concentration (Cr)')
% 
%     subplot(235)
%     plot(tout_5_b, simout_5_b(:, 3))
%     hold on
%     plot(tout_5_b, simout_5_b(:, 4))
%     hold off
%     legend('Ref', 'Actual')
%     grid, ylabel('Reactor Temperature (Tr)'), xlabel ('time (s)')
%     
%     subplot(233)
%     plot(tout_10_b, simout_10_b(:, 1))
%     hold on
%     plot(tout_10_b, simout_10_b(:, 2))
%     hold off
%     legend('Ref', 'Actual')
%     grid, title('10% noise simulated'), ylabel('Residual Concentration (Cr)')
% 
%     subplot(236)
%     plot(tout_10_b, simout_10_b(:, 3))
%     hold on
%     plot(tout_10_b, simout_10_b(:, 4))
%     hold off
%     legend('Ref', 'Actual')
%     grid, ylabel('Reactor Temperature (Tr)'), xlabel ('time (s)')
%     
%     sgtitle('Brain trained with 5% noise')
% end

%% Comparison Plot

load benchmarkRMS.mat

x = categorical({'Concentration RMS', 'Temp RMS'});
x = reordercats(x, {'Concentration RMS', 'Temp RMS'});
y = [metric_rms_C_bench metric_rms_C_brain; 
     metric_rms_T_bench metric_rms_C_brain];
 
x5 = categorical({ 'Concentration RMS - 5% noise', 'Temp RMS - 5% nosie'});
x5 = reordercats(x5, {'Concentration RMS - 5% noise', 'Temp RMS - 5% nosie'});
y5 = [metric_rms_C_bench_5 metric_rms_C_brain_5;
     metric_rms_T_bench_5 metric_rms_T_brain_5];
 
 
% x5 = categorical({'Concentration RMS - 0% noise', 'Temp RMS - 0% noise', 'Concentration RMS - 5% noise', 'Temp RMS - 5% nosie'});
% x5 = reordercats(x5, {'Concentration RMS - 0% noise', 'Temp RMS - 0% noise', 'Concentration RMS - 5% noise', 'Temp RMS - 5% nosie'});
% y5 = [metric_rms_C_bench metric_rms_C_brain; 
%      metric_rms_T_bench metric_rms_C_brain; 
%      metric_rms_C_bench_5 metric_rms_C_brain_5;
%      metric_rms_T_bench_5 metric_rms_T_brain_5];
%  
 figure

    subplot(221)
    plot(tout_0_b, simout_0_b(:, 1))
    hold on
    plot(tout_0_b, simout_0_b(:, 2))
    hold off
    legend('Ref', 'Actual')
    grid, title('0% noise simulated'), ylabel('Residual Concentration (Cr)')

    subplot(223)
    plot(tout_0_b, simout_0_b(:, 3))
    hold on
    plot(tout_0_b, simout_0_b(:, 4))
    hold off
    legend('Ref', 'Actual')
    grid, ylabel('Reactor Temperature (Tr)'), xlabel ('time (s)')
    
    subplot(222)
    plot(tout_5_b, simout_5_b(:, 1))
    hold on
    plot(tout_5_b, simout_5_b(:, 2))
    hold off
    legend('Ref', 'Actual')
    grid, title('5% noise simulated'), ylabel('Residual Concentration (Cr)')

    subplot(224)
    plot(tout_5_b, simout_5_b(:, 3))
    hold on
    plot(tout_5_b, simout_5_b(:, 4))
    hold off
    legend('Ref', 'Actual')
    grid, ylabel('Reactor Temperature (Tr)'), xlabel ('time (s)')
    
    
    sgtitle('Brain trained with 5% noise')