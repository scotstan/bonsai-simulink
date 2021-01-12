%% Thermal Model of a House

clear;
close all;
clc;

%% Initalize Parameters
n_rooms =  1;
nWindows_room1 = 6;
nWindows_room2 = 6;
nWindows_room3 = 6;

init_vars

%% Benchmark

initToutdoor = 60;
sim('buildingEnergyManagement.slx')

for i = 1:n_rooms
    mae(simout(:, i+1), simout(:, 1), i)
end
disp(['Cost = $', num2str(round(simout(end, 7), 2))]) 

plot_results(tout, simout)

%% Benchmark Hot Day

initToutdoor = 95;
sim('buildingEnergyManagement.slx')

for i = 1:n_rooms
    mae(simout(:, i+1), simout(:, 1), i)
end
disp(['Cost = $', num2str(round(simout(end, 7), 2))]) 

plot_results(tout, simout)

%% Benchmark Cold Day

initToutdoor = 35; %[F]
sim('buildingEnergyManagement.slx')

for i = 1:n_rooms
    mae(simout(:, i+1), simout(:, 1), i)
end
disp(['Cost = $', num2str(round(simout(end, 7), 2))]) 

plot_results(tout, simout)

%% Functions

function [] = plot_results(tout, simout)
    figure
    subplot(411)
    plot(tout, simout(:, 7))
    grid, title('Cost'), ylabel('Cost [$]')

    subplot(412)
    plot(tout, simout(:, 1))
    hold on
    plot(tout, simout(:, 2))
    plot(tout, simout(:, 3))
    plot(tout, simout(:, 4))
    hold off
    legend('Tset', 'Troom1', 'Troom2', 'Troom3')
    grid, title(''), ylabel('Inside Temperature [\circF]')

    subplot(413)
    plot(tout, simout(:, 6))
    hold on
    plot(tout, simout(:, 2))
    plot(tout, simout(:, 3))
    plot(tout, simout(:, 4))
    hold off
    legend('Toutdoor', 'Troom1', 'Troom2', 'Troom3')
    grid, title('Temperature'), ylabel('Temperature [\circF]')
    
    subplot(414)
    plot(tout, simout(:, 8),'.')
    grid, title('Action')
    xlabel('Hours')
    ylim([1 3]); yticks([1 2 3]); yticklabels({'AC','Heat','Off'})
end

function [] = mae(set, actual, roomnum)
    metric_mae = mean(abs(actual - set));
    disp(['Mean Absolute Error for Room ', num2str(roomnum),' = ', num2str(metric_mae), 'F'])
end

%% Return to Simulink Defaults