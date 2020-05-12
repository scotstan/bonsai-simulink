function trainMoab()

% Run variable initialization script
MOAB_PARAMS;

% Load the model
mdl = 'MOAB';
open_system(mdl);

% Turn on fast restart for the model
set_param(mdl,'FastRestart','on');

% Set options for training
doTraining = true;
maxEpisodes = 250;
iter = 1;

MaxInitialVelocity = 0.05;

while doTraining
    
    % Modify ball parameters 
    ball_radius = 0.01 + 0.04*rand;
    ball_mass   = DEFAULT_BALL_MASS;
    ball_shell  = DEFAULT_BALL_SHELL;
    target_pos_x = 0;
    target_pos_y = 0;
    
    % Recalculate variables affected by ball parameter changes
    ball_z0 = DEFAULT_PLATE_HEIGHT + PLATE_ORIGIN_TO_SURFACE_OFFSET + ball_radius;
    ball_moi  = calcMOI(ball_radius,ball_shell,ball_mass);
    [ball_stiffness, ball_damping, ball_transitionwidth] = ...
        cor2SpringDamperParams(DEFAULT_BALL_COR,ball_mass);
    
    
    
    

    
    % Create a simulation input object to set the variables
    in = Simulink.SimulationInput(mdl);
    in = in.setVariable('ball_radius',ball_radius);
    in = in.setVariable('ball_mass',ball_mass);
    in = in.setVariable('ball_shell',ball_shell);
    in = in.setVariable('target_pos_x',target_pos_x);
    in = in.setVariable('target_pos_y',target_pos_y);
    in = in.setVariable('ball_z0',ball_z0);
    in = in.setVariable('ball_moi',ball_moi);
    in = in.setVariable('ball_stiffness',ball_stiffness);
    in = in.setVariable('ball_damping',ball_damping);
    in = in.setVariable('ball_transitionwidth',ball_transitionwidth);


    in = in.setVariable('ball_x0',-DEFAULT_PLATE_RADIUS + 2*DEFAULT_PLATE_RADIUS*rand);
    in = in.setVariable('ball_y0',-DEFAULT_PLATE_RADIUS + 2*DEFAULT_PLATE_RADIUS*rand);
    
    in = in.setVariable('ball_vel_x0',-MaxInitialVelocity + 2*MaxInitialVelocity*rand);
    in = in.setVariable('ball_vel_y0',-MaxInitialVelocity + 2*MaxInitialVelocity*rand);

    % Run the simulation
    sim(in);
    
    % Loop until maxEpisodes.
    iter = iter + 1;
    doTraining = iter <= maxEpisodes;
end

% Exit fast restart
%set_param(mdl,'FastRestart','off')