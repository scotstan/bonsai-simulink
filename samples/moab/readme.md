
# Moab Overview
<img src="images/hero.png" alt="The Moab M2 robot" width="400" style="float: right; ">
Project Moab is a small balancing robot useful for demonstrating machine teaching on a physical device for Engineers. Project Moab is based on a basic problem: keep a ball balanced on top of a plate held by three arms. But rather than using differential equations and other traditional ways of solving the problem, an engineer will instead teach the AI system how to balance it. Users can very quickly take it into areas where doing it in traditional ways would not be easy, such as balancing an egg instead of a ball.

The Moab M2 robot is an optional companion for Project Bonsai. The Bonsai Azure service contains a complete simulation of Moab, allowing one to experience machine teaching in software. The trained brain can then be downloaded to the bot, allowing direct control.

To learn more about Project Moab, including all of the schematics, check out http://aka.ms/moab. 

<!--## Required Toolboxes 

The following toolboxes are required for the Moab example:

### Bonsai Toolbox
The Bonsai Toolbox is a free add-in for connecting your Simulink model to the Microsoft Bonsai platform to be used to train an AI agent based on the states and actions outlined in the model. 

To learn more about Bonsai, check out https://docs.microsoft.com/en-us/bonsai/.

### SimScape
Simscape™ enables you to rapidly create models of physical systems within the Simulink® environment. With Simscape, you build physical component models based on physical connections that directly integrate with block diagrams and other modeling paradigms. You model systems such as electric motors, bridge rectifiers, hydraulic actuators, and refrigeration systems, by assembling fundamental components into a schematic. Simscape add-on products provide more complex components and analysis capabilities.

Simscape helps you develop control systems and test system-level performance. You can create custom component models using the MATLAB® based Simscape language, which enables text-based authoring of physical modeling components, domains, and libraries. You can parameterize your models using MATLAB variables and expressions, and design control systems for your physical system in Simulink. To deploy your models to other simulation environments, including hardware-in-the-loop (HIL) systems, Simscape supports C-code generation.

For more details, check out https://www.mathworks.com/products/simscape.html.-->


# Model Overview
Moab is a dynamic ball-on-plate system is modeled using Simulink and Simscape Multibody. The model contains blocks that represent the multi-body system using imported 3d-CAD parts, joints, contact forces, constraints and sensors. Simscape Multibody formulates and solves the equations of motion for the complete system. During simulation, the system’s states are extracted and sent to a Reinforcement Learning controller (the Bonsai block) which provides the necessary actuation signals to control the plate tilt angles, thus balancing the ball on the plate.

To run the model the following products are required:
1.	Simulink Version 10.0 (R2019b)
2.	Simscape Multibody (R2019b)
3.	Bonsai Toolbox 1.0
4.  Bonsai <a href="https://docs.microsoft.com/en-us/bonsai/quickstart/setup">account</a>


## Solver 
To simulate the model, a solver computes the states of the system at successive time steps by applying a numerical method. This numerical method solves a set of ordinary differential equations (ODEs) that represent the ball-on-plate system, in addition to determining the time of the next simulation step and satisfying accuracy requirements. In addition to dynamic behavior, physical systems may have algebraic constraints representing functional relationships between states. To satisfy these constraints along with the ODEs, the model uses a differential algebraic equation (DAE) solver.

The choice of solver for this model is ode23t, which solves moderately stiff ODEs and DAEs with a trapezoidal integration rule. Learn more about ode23t here:
https://www.mathworks.com/help/matlab/ref/ode23t.html
  
Other things people might consider --
 
**How Simscape models represent physical systems**\
https://www.mathworks.com/help/physmod/simscape/ug/how-simscape-models-represent-physical-systems.html

**Choose an ODE solver**\
https://www.mathworks.com/help/matlab/math/choose-an-ode-solver.html

**Making optimal solver choices for physical simulation:**\
https://www.mathworks.com/help/physmod/simscape/ug/making-optimal-solver-choices-for-physical-simulation.html

**How Fast Restart improves iterative simulations**\
https://www.mathworks.com/help/simulink/ug/how-fast-restart-improves-iterative-simulations.html


## Runtime vs. Compiled Variables

During training, resetting some of the initial states of the model helps the reinforcement learning agent in the Bonsai block learn better. These states are automatically reset by the training algorithm at the start of each episode. To avoid model recompilation due to these changes, the model is simulated in <a href="https://www.mathworks.com/help/simulink/ug/how-fast-restart-improves-iterative-simulations.html">Fast Restart</a> mode and corresponding Simscape block parameters are set to run-time tunable mode.

| **State** | **Variable name** | **Simscape block** |
| --- | --- | --- |
| Initial height of the plate | plate\_pos\_z0 | MOAB/MOAB/Simscape Model/6-DOF Joint Plate |
| Initial plate tilt angles | tilt\_x0, tilt\_y0 | MOAB/MOAB/Simscape Model/6-DOF Joint Plate |
| Initial servo angles | arm1\_alpha0, arm2\_alpha0, arm3\_alpha0 | MOAB/MOAB/Simscape Model/Motor 1/Revolute Joint2MOAB/MOAB/Simscape Model/Motor 2/Revolute Joint1MOAB/MOAB/Simscape Model/Motor 3/Revolute Joint |
| Initial ball position | ball\_x0, ball\_y0, ball\_z0 | MOAB/MOAB/Simscape Model/Sensor/Ball Sensing/6-DOF Joint Ball |
| Initial ball velocity | ball\_vel\_x0, ball\_vel\_y0 | MOAB/MOAB/Simscape Model/Sensor/Ball Sensing/6-DOF Joint Ball |
| Ball radius, mass, inertia | ball\_radius, ball\_mass, ball\_moi | MOAB/MOAB/Simscape Model/Ball/Ball |
| Contact force parameters between ball and plate | ball\_stiffness, ball\_damping, ball\_transitionwidth | MOAB/MOAB/Simscape Model/Spatial Contact Force |
| Obstacle position | obstacle\_pos\_x0, obstacle\_pos\_y0 | MOAB/MOAB/Simscape Model/Sensor/Obstacle Sensing/Obstacle Transform XMOAB/MOAB/Simscape Model/Sensor/Obstacle Sensing/ Obstacle Transform Y |

To enable view of run-time parameter settings, turn on MATLAB > Home > Preferences > Simscape > Show run-time parameter settings.


## Bonsai Toolbox Sample Time

The Bonsai block will operate at a discrete sample time of 0.02s. This is the rate at which the block will be executed during simulation and may be different from the model’s sample time which is stepped up and down while the solver computes the states.


# Running the Model

There are two ways to run the model. The first is to test the model with the output states from the Moab subsystem connected to the local sinusoidal block. This enables you to run the model without the connection to Bonsai to get an understanding of how the model works.

## Run locally, without Bonsai
To start the model, run the **startup_MOAb** script from the MATLAB command prompt. This will launch the MOAB.slx model. 

You can set the variable *useBonsai* to 0 to not use Bonsai. 

If you prefer to use the UI, you can double-click on the Sinusoidal or Bonsai block and change the value in the dropdown, as shown below:

<img src="images/change_local_bonsai.png" width="700" alt="Sinusoidal or Bonsai prompt">

If you would like to test by changing various parameters, you can run the **Scripts_Data/runMoabLocalLoop.m** script.  This is a representation of what the Bonsai platform will do once the model is connected to the Bonsai platform. 

### Modifying Parameters
In both examples you will see that there are a number of parameters that get modified during a training loop. You may also notice calls to *runMixer*, *calcMOI*, and *cor2SpringDamperParams* functions. These are used to reset the system to the proper initialization steps after the variable values are changed. 

## Run locally, with Bonsai

After getting acclimated with the Moab model and setting up a Bonsai account, you are now ready to train your first Bonsai brain for Moab. Be sure to select **Yes** in the Sinusoidal or Bonsai block and save your model. 

There are two scripts that are used to connect your model to Bonsai: **bonsaiConfig** and **bonsaiTrain**.

### bonsaiConfig

The **bonsaiConfig** script contains the BonsaiConfig function. This is used to setup the connection between your model and the Bonsai platform. Here you describe several key factors:

- **name** - The name of your simulator (you will see this when you connect to Bonsai)
- **url** - Optional. The URL used to connect the Bonsai API service
- **timeout** -- Optional. The value in seconds for a timeout. A default value of 60 seconds is used if this is not explicitly set.
- **workspace** - The workspace value obtained from the Bonsai platform.
- **accessKey** - the access key obtained from the Bonsai platform.
- **outputCSV** - Optional. When running locally, this can be helpful for debugging your model and the Bonsai connection.
- **stateSchema** - *Important.* This is the *order* of the values as they appear in the input parameter of the Bonsai block. Even if you use a Bus as your input the Bonsai block must understand the order of the values. These names must match what is in your inkling code in Bonsai. 
- **actionSchema** - The actions the brain will perform. Input ports to the Moab subsystem. The names must match what is in your inkling code from Bonsai. Order is important. 
- **configSchema** - The values that the Bonsai brain will send during a training episode. These are used as configuration parameters to initialize the model with different states, such as ball size, position, or velocity. 

> A note about states: Your model may contain more states than what is in your inkling code for Bonsai. It is OK to have additional states that you send - these are ignored by the platform during execution. However, you must send all states that are required by the inkling code. If you do not, you will receive an error from the platform with an immediate Unregister command.

Below is the bonsaiConfig file for Moab:

```Matlab
function config = BonsaiConfig()
    config = BonsaiConfiguration();
    config.url = "https://api.bons.ai";
    config.name = "Simulink - Moab";
    config.timeout = 120;
    
    % bonsai workspace
    config.workspace = "<your workspace here>";

    % access key, generated from https://beta.bons.ai/brains/accounts/settings
    config.accessKey = "<your access key here>";

    config.outputCSV = "moab_log.csv";
    
    %these are in the order of the inport
    config.stateSchema = ["pitch", ...
                          "roll", ...
                          "ball_noise","plate_noise", ...
                          "plate_pos_x","plate_pos_y","plate_pos_z", ...
                          "plate_nor_x","plate_nor_y","plate_nor_z", ...
                          "ball_x","ball_y","ball_z", ...
                          "ball_vel_x","ball_vel_y","ball_vel_z", ...
                          "estimated_x","estimated_y", ...
                          "estimated_radius", ...
                          "estimated_vel_x","estimated_vel_y", ...
                          "ball_qat_x","ball_qat_y","ball_qat_z","ball_qat_w", ...
                          "ball_fell_off", ...
                          "iteration_count", ...
                          "ball_mass","ball_radius","ball_shell", ...
                          "target_x","target_y", ...
                          "obstacle_radius","obstacle_distance", "obstacle_direction","obstacle_x", "obstacle_y", ...
                          "ball_on_plate_x","ball_on_plate_y","ball_on_plate_z", ...
                          "plate_theta_x","plate_theta_y", "plate_theta_acc", "plate_theta_limit","plate_theta_vel_limit", ...
                          "time_delta"];
    config.actionSchema = ["input_pitch","input_roll"];
    config.configSchema = ["initial_x","initial_y","initial_pitch","initial_roll","initial_vel_x","initial_vel_y", ...
                           "ball_radius", ...
                           "obstacle_x","obstacle_y","obstacle_radius"];
    config.verbose = true;
end
```

In this example there are multiple lines for the config schema. Each tutorial, located below, uses a different set of the config parameters. Every tutorial uses the first line above. The second tutorial uses the second line. The third tutorial uses the third line. You will see in the bonsaiTrain.m file how these interact with each other.

### bonsaiTrain

Once you have configured your connection to the Bonsai platform using bonsaiConfig, you are ready to run the **bonsaiTrain** script.  This script is used to connect your model to the Bonsai platform and get per-time-step information (called an iteration in Bonsai) that is used to train the Bonsai brain. 

> Be sure that your model is saved with the **Yes** option for the *Sinusoidal or Bonsai* block.

You should not need to modify any values in the bonsaiTrain script, but to help clarify a few areas that happen in the script:

When you are running bonsaiTrain locally, you may want to see the Mechanics Explorer so you can see the ball position both locally and compare it to how the visualization is displayed in the Bonsai dashboard. However, once you upload your model to the Bonsai server environment you cannot see the model, so it is disabled. If you attempt to render the model in the server environment the connection will likely timeout and training will not start correctly.

```matlab
% are we running in our local desktop
if usejava('desktop')
    disp('showing Mechanics Explorer');
    set_param(mdl,'SimMechanicsOpenEditorOnUpdate','on');
else %or in the Bonsai server environment?
    disp('hiding Mechanics Explorer');
    set_param(mdl,'SimMechanicsOpenEditorOnUpdate','off'); %
end
```

The general flow of Bonsai is:

1. Session register
2. Episode start
3. Receive callback with initialization parameters 
4. Send episode step information using the State inputs
5. Receive an Action from Bonsai
6. The Bonsai Action is an input to a subsystem
7. Steps 5 and 6 are repeated until an episode End event or an error occurs
8. Upon an episode End event, the model will close and the Bonsai toolbox will create a new Episode. Steps 2-8 will repeat.

Another area to call out is the *episodeStartCallback* function. Again, it is not necessary to change anything, but the code is present here to understand what is happening under the hood. 

When Bonsai initiates a training session, a callback is fired and handled here. This allows the user to configure their model environment and set parameters to what their model requires. It is also in this command that the user starts their simulation. Some users may choose to pass just the *mdl* to *sim()* while others have more dynamic SimulationInput requirements, like below:

- Each time you start a new training Episode in Bonsai, the Bonsai brain will send initial start up parameters that can be used to initialize the model to set it to various states
- The Moab model is used in all three <a href="#tutorials">tutorials</a>. However, each tutorial has a slightly different set of parameters. All tutorials use the first set of variables (tilt_x0. tilt_y0, etc). We use the *isfield* function to determine whether a configuration parameter is included and then set the parameter values accordingly. 

```matlab
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
        
        % Recalculate variables affected by ball parameter changes
        ball_shell = evalin('base','DEFAULT_BALL_SHELL');
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
```

#### Test your Model

Before you upload your model using the Bonsai platform it is recommended to test it first to confirm functionality. In the Bonsai dashboard click the **+ Create Brain** button. Select **Moab demo** and enter a name. In this example, the brain is called **demo-moab**. 

Find the following section of the ihkling code on the Teach tab:

```
source simulator (Action: SimAction, Config: SimConfig): SimState {
    # Automatically launch the simulator with this
    # registered package name.
    package "BonsaiMoabSimV4"
}
```

You need to remove the package statement, so the above would read:

```
source simulator (Action: SimAction, Config: SimConfig): SimState {
   
}
```

The inkling code will save automatically. 

Now run the **bonsaiTrian** script from the MATLAB command prompt. Assuming you have configured your workspace and access keys correctly in bonsaiConfig, you should see code indicating the simulator registered successfully. 

Now, in the Bonsai dashboard, click the **Train** button. Select **Simulink - Moab** simulator (this assumes you left the .name value the same in bonsaiConfig). After a short time you will will see your first episode start event and data start flowing to the brain. 

# Upload and Scale Your Model

Once you have exported your model, you can zip the entire contents of the folder that contains the exported application. 

For example, if your folder structure is:

```
moab
└─── CAD
|    └── ... step files ...   
└─── Images
|    └── ... image files ...      
└─── Scripts_Data
|    └── calcMOI.m
|    └── cor2SpringDamperParams.m   
|    └── MOAB_PARAMS.m  
|    └── runMixer.m
|    └── runMoabLocalLoop.m
|─── bonsaiConfig.m
|─── bonsaiTrain.m
|─── MOAB.slx
|─── readme.md
└─── startup_MOAB.m
```

Then you only need to zip the parent **moab** folder. Call it moab.zip. 

Back in the Bonsai dashboard, next to **Simulators**, click the **Add sim** button.

This will open a dialog. Select MathWorks. Select or drag the moab.zip file . Give your simulator a name, then click **Create simulator**. 

After the simulator is created you will see the new simulator appear under the **Simulators** section.

Now click the *Teach* tab. 

In the simulator definition, just after the open brackets, add back the package statement using the name of the simulator you gave during the Add Simulator dialog above.

```
simulator Simulator(action: Action, config: SimConfig): SimState {
	package "<simulator_name_from_upload>"
}
```

Now click **Train**. Since you indicated the package name you do not need to select a simulator from the dropdown like you did when you started locally.

In a few minutes time you will see several simulators connect to and train your brain.  

# Tutorials<a name="tutorials"></a>

There are a number of tutorials outlined on the Project Moab microsite, so the step by step instructions are not repeated here. When you run the inkling in the tutorials, remember to change your package name to *<simulator_name_from_upload>* to use your uploaded Simulink model for the tutorials.

Below you will see some examples about how the Simulink model performs during the tutorials.

## Tutorial 1

<a href="https://aka.ms/moab/tutorial1">Tutorial 1</a> is introduces you to the machine teaching paradigm used by Moab and how to integrate with the Moab model. The Moab model has been designed to be used with the same inkling that is in tutorial 1. However, you will change the package statement to use your uploaded Moab model.

Speed will vary, but after about 318,000 iterations, the brain will achieve its goals:

<img src="images/tut_1_results.png" alt="Tutorial 1 results" width="800" border="1">

## Tutorial 2
<a href="https://aka.ms/moab/tutorial2">Tutorial 2</a> introduces domain randomization. Domain randomization is used to train the brain to use allow Moab to balance balls other than a ping pong ball.

Speed will vary, but after about 474,000 iterations, the brain will achieve its goals:

<img src="images/tut_2_results.png" alt="Tutorial 2 results" width="800" border="1">

## Tutorial 3
 https://aka.ms/moab/tutorial3

<!--# Using Bonsai Assessment with Your Model
tbd-->
