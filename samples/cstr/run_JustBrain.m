%% Run the sample with benchmark and brain and plot results
% This script can be run once you have trained, exported, and are locally
% running a brain
% Specify the brain endpoint on line 18

clear;
%close all;
clc;

%% Set simulation configuration

% Set Cref_signal
signal = 2;

% Set noise
noise = 10;

% Set brain version
% Brain = 'http://localhost:5010/v1/prediction'; % Multiconcept brain steady state vs transient trained with 0-5% noise
Brain = 'http://localhost:5015/v1/prediction'; % Monolithic brain trained with 0-5% noise

%% Initialize Workspace for Brain

% Initial data required for compilation should be initialized
init_vars

% load model and disable fast restart
mdl = 'ChemicalProcessOptimization_Bonsai';
load_system(mdl);
set_param(mdl, 'FastRestart', 'off');

% configure exported brain
config = bonsaiConfig;
config.exportedBrainUrl = Brain; 
BonsaiConfigureExportConnect(config, mdl);

init_vars

% Residual Concentration Range
Cr_vec = [2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9];

open_system('ChemicalProcessOptimization_Bonsai')
%set_param('ChemicalProcessOptimization/Variant Subsystem', 'VChoice', 'Bonsai')

Cref_signal=signal;

%% Run Brain without noise

sim('ChemicalProcessOptimization_Bonsai');

tout_b = tout;
simout_b = simout;

%% Run Brain with noise

% Percentage of noise to include
noise_magnitude = noise/100;

% Auxiliary params
conc_noise = abs(CrEQ(1)-CrEQ(5))*noise_magnitude;
temp_noise = abs(TrEQ(1)-TrEQ(5))*noise_magnitude;

sim('ChemicalProcessOptimization_Bonsai');

tout_b_noise = tout;
simout_b_noise = simout;

%% Save data as CSV

% Benchmark without noise
SimData =[tout_PI simout_PI];
csvwrite(['Data_PI.csv'],SimData);

% Benchmark with noise
SimData =[tout_PI_noise simout_PI_noise];
csvwrite(['Data_PI_', num2str(noise),'.csv'],SimData);

% Brain without noise
SimData =[tout_b simout_b];
csvwrite(['Data_b.csv'],SimData)

% Brain with noise
SimData =[tout_b_noise simout_b_noise];
csvwrite(['Data_b_', num2str(noise),'.csv'],SimData)

%% Plot

plot_comparison2(tout_b, simout_b,tout_b_noise, simout_b_noise,noise)


%%
function []=plot_comparison2(tout_b, simout_b,tout_b_noise, simout_b_noise, noise)

    % Calculate Error RMS of concentration
    metric_rms_C_brain = sqrt(mean((simout_b(:, 1) - simout_b(:, 2)).^2));
    metric_rms_C_brain_noise = sqrt(mean((simout_b_noise(:, 1) - simout_b_noise(:, 2)).^2));
    
%     % Generate bar graph variables
%     x = categorical({'Benchmark', 'Brain'});
%     x = reordercats(x, {'Benchmark', 'Brain'});
%     y = [metric_rms_C_bench metric_rms_C_brain]; 
% 
%     x5 = categorical({'Benchmark', 'Brain'});
%     x5 = reordercats(x5, {'Benchmark', 'Brain'});
%     y5 = [metric_rms_C_bench_noise metric_rms_C_brain_noise];
%     
%     % Find max temp reached
%     Tmax_brain = max(simout_b(:,4));
%     Tmax_brain_5 = max(simout_b_noise(:,4));
% 
%     % Generate bar graph variables
%     xT = categorical({'Benchmark', 'Brain'});
%     xT = reordercats(xT, {'Benchmark', 'Brain'});
%     yT = [Tmax_bench; Tmax_brain];
% 
%     xT5 = categorical({'Benchmark', 'Brain'});
%     xT5 = reordercats(xT5, {'Benchmark', 'Brain'});
%     yT5 = [Tmax_bench_5; Tmax_brain_5];
    
    figure
    sgtitle('Bonsai Brain vs. Benchmark (Gain Scheduled PI Control)')
    
    % plot results with 0% noise
    subplot(221) 
        plot(tout_b, simout_b(:, 1),'LineStyle','--')
        hold on
        plot(tout_b, simout_b(:, 2),'color','blue')
        hold off
        ylim([0 11])
        legend('Ref', 'Brain','Benchmark','Location','southwest')
        grid, title('0% noise simulated'), ylabel('Residual Concentration (Cr)')

    subplot(223)
        plot(tout_b, simout_b(:, 3),'LineStyle','--')
        hold on
        plot(tout_b, simout_b(:, 4),'color','blue')
        hold off
        ylim([250 450])
        legend('Ref', 'Brain','Benchmark','Location','northwest')
        grid, ylabel('Reactor Temperature (Tr)'), xlabel ('time (s)')
    
    % plot results 5% noise
    subplot(222)
        plot(tout_b_noise, simout_b_noise(:, 1),'LineStyle','--')
        hold on
        plot(tout_b_noise, simout_b_noise(:, 2),'color','blue')
        hold off
        ylim([0 11])
        legend('Ref', 'Brain','Benchmark','Location','southwest')
        grid, title([num2str(noise),'% noise simulated']), ylabel('Residual Concentration (Cr)')

    subplot(224)
        plot(tout_b_noise, simout_b_noise(:, 3),'LineStyle','--')
        hold on
        plot(tout_b_noise, simout_b_noise(:, 4),'color','blue')
        hold off
        ylim([250 450])
        legend('Ref', 'Brain','Benchmark','Location','northwest')
        grid, ylabel('Reactor Temperature (Tr)'), xlabel ('time (s)')
    
%     % Plot Error RMS of Cencentration
%     subplot(425)
%         bar(x,y);
%         ylabel('RMS of error'),
%         ylim([0 5])
% 
%      subplot(426)
%          bar(x5,y5)
%          ylabel('RMS of error'),
%          ylim([0 5])
% 
%      % Plot max temp
%      subplot(427)
%          bar(xT,yT)
%          hold on
%          yline(400,'LineStyle','--','LineWidth',2)
%          title('Max Temperature - 0% noise simulated'),
%          ylabel('Reactor Temperature'),
%          ylim([0 500])
% 
%      subplot(428)
%          bar(xT5,yT5)
%          hold on
%          yline(400,'LineStyle','--','LineWidth',2)
%          title(['Max Temperature - ',num2str(noise),'% noise simulated'])
%          ylabel('Reactor Temperature'),
%          ylim([0 500])
%%
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
end

