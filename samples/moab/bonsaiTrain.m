
%load the paths
folder_pathlist = {...
    'CAD'...
    'Images'...
    'Scripts_Data'...
    };
addpath(pwd);
for i=1:length(folder_pathlist)
    addpath([pwd filesep folder_pathlist{i}]);
end

% Run variable initialization script
MOAB_PARAMS

% load model and enable fast restart
mdl = 'MOAB';

load_system(mdl);

% for performance
set_param(mdl, 'FastRestart', 'on');

% are we running in our local desktop
if usejava('desktop')
    disp('showing Mechanics Explorer');
    set_param(mdl,'SimMechanicsOpenEditorOnUpdate','on');
else %or in the Bonsai server environment?
    disp('hiding Mechanics Explorer');
    set_param(mdl,'SimMechanicsOpenEditorOnUpdate','off'); %
end

% run training
config = bonsaiConfig;
BonsaiRunTraining(config, mdl, @episodeStartCallback);

% callback for setting the model's initial episode configuration
function episodeStartCallback(mdl, episodeConfig)
    
    in = Simulink.SimulationInput(mdl);
    
    tilt_x0 = episodeConfig.initial_pitch;
    tilt_y0 = episodeConfig.initial_roll;
    
    in = in.setVariable('tilt_x0',tilt_x0);
    in = in.setVariable('tilt_y0',tilt_y0);
    in = in.setVariable('ball_x0',episodeConfig.initial_x);
    in = in.setVariable('ball_y0',episodeConfig.initial_y);
    
    in = in.setVariable('ball_vel_x0',episodeConfig.initial_vel_x);
    in = in.setVariable('ball_vel_y0',episodeConfig.initial_vel_y);
    
    h = evalin('base','DEFAULT_PLATE_HEIGHT+z_offset');
    [a1,a2,a3] = runMixer(h, tilt_x0, tilt_y0);
    
    in = in.setVariable('arm1_alpha0',a1);
    in = in.setVariable('arm2_alpha0',a2);
    in = in.setVariable('arm3_alpha0',a3);
    
    %tutorial 2
    if isfield(episodeConfig, 'ball_radius') == 1
        disp('running tutorial 2');
        
        
        ball_radius = episodeConfig.ball_radius;
        ball_shell = episodeConfig.ball_shell;
   
        % Recalculate variables affected by ball parameter changes
        ball_mass = evalin('base','DEFAULT_BALL_MASS');
        ball_cor = evalin('base','DEFAULT_BALL_COR');
        ball_z0 = evalin('base','DEFAULT_PLATE_HEIGHT + PLATE_ORIGIN_TO_SURFACE_OFFSET') + ball_radius;
        ball_moi  = calcMOI(ball_radius,ball_shell,ball_mass);
        [ball_stiffness, ball_damping, ball_transitionwidth] = cor2SpringDamperParams(ball_cor,ball_mass);
        
        in = in.setVariable('ball_radius',ball_radius);
        in = in.setVariable('ball_mass',ball_mass);
        in = in.setVariable('ball_shell',ball_shell);
        in = in.setVariable('ball_z0',ball_z0);

        in = in.setVariable('ball_stiffness',ball_stiffness);
        in = in.setVariable('ball_damping',ball_damping);
        in = in.setVariable('ball_transitionwidth',ball_transitionwidth);
        in = in.setVariable('ball_moi',ball_moi);    
    end
   
    %tutorial 3
    if isfield(episodeConfig, 'obstacle_radius') == 1
        disp('running tutorial 3');
        
        ob_radius = episodeConfig.obstacle_radius;
       
        %assignin('base','obstacle_radius',ob_radius);
        in = in.setVariable('obstacle_radius',ob_radius);
        in = in.setVariable('obstacle_pos_x0',episodeConfig.obstacle_x);
        in = in.setVariable('obstacle_pos_y0',episodeConfig.obstacle_y);
        
    end
    
    %start the model
    sim(in);
end
