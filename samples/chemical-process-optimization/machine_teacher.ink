###

# MSFT Bonsai 
# Copyright 2021 Microsoft
# This code is licensed under MIT license (see LICENSE for details)

# CPO - Chemical Process Optimization
# This introductory sample demonstrates how to teach a policy for 
# controlling a chemical process, specifically a CSTR, Continuous
# Stirred Tank Reactor

###

inkling "2.0"

using Math
using Number
using Goal

# Sim Period
const Ts = 0.5
# Coolant temperature derivative limit per minute
const coolant_temp_deriv_limit_per_min = 10
# Coolant temperature acceleration limit
const coolant_temp_acc_limit_per_min = 2*coolant_temp_deriv_limit_per_min/Ts
# Coolant temperature derivative limit
const coolant_temp_deriv_limit = Ts*coolant_temp_deriv_limit_per_min

# Limits for concentration
const conc_max = 10
const conc_min = 0.5
const conc_delta_target = 0.8883
const conc_delta_max = 3*conc_delta_target

# Limits for temperature
const temp_max = 500
const temp_min = 100
const temp_delta_target = 9.4691
const temp_delta_max = 3*temp_delta_target

# Coolant temperature control on OPTION 2 (Tc_delta)
const coolant_temp_ini = 297.9798
const coolant_temp_min = temp_min-coolant_temp_ini  # Based on benchmark, this could be set to -20
const coolant_temp_max = temp_max-coolant_temp_ini  # Based on benchmark, this could be set to +20
const coolant_temp_max_diff = temp_max-temp_min

# Common limit to make equilibrium goals more strict
const equilibrium_divisor = 10

# Accumulated values --> absolutely added variables along each episode
const conc_error_accumulated_max = 180*conc_delta_max
const temp_error_accumulated_max = 180*temp_delta_max
const dTc_error_accumulated_max = 180*coolant_temp_max
const conc_accumulated_target = 26*conc_delta_target
const temp_accumulated_target = 26*temp_delta_target
const dTc_accumulated_target = 13*coolant_temp_deriv_limit


# State received from the simulator after each iteration
type SimState {
    # Concentration: Real-time reactor read
    Cr: number<conc_min .. conc_max>,
    # Temperature: Real-time reactor read
    Tr: number<temp_min .. temp_max>,
    
    # Concentration: Real-time reactor read without noise (no matter noise value)
    Cr_no_noise: number<conc_min .. conc_max>,
    # Temperature: Real-time reactor read without noise (no matter noise value)
    Tr_no_noise: number<temp_min .. temp_max>,

    # Concentration: Target reference to follow
    Cref: number<conc_min .. conc_max>,
    # Temperature: Target reference to follow
    Tref: number<temp_min .. temp_max>,

    # Concentration Error: Cr-Cref
    Cref_error: number<-5*conc_delta_max .. 5*conc_delta_max>,
    # Temperature Error: Tr-Tref
    Tref_error: number<-5*temp_delta_max .. 5*temp_delta_max>,

    # Reactor Concentration' Acceleration (derivative of derivative) - Accumulating absolute
    Cref_error_abs_accumulated: number<0 .. conc_error_accumulated_max>,
    # Reactor Temperature' Acceleration (derivative of derivative) - Accumulating absolute
    Tref_error_abs_accumulated: number<0 .. temp_error_accumulated_max>,

    # Current state is equilibrium
    #  - during transition: eq == 0
    #  - after and before transition: eq == 1)
    equilibrium: number<0 .. 1>,
    
    # Reactor control dTc ==> Tc(t)-Tc(t-1)
    dTc_increment: number<-coolant_temp_max_diff .. coolant_temp_max_diff>,
    # Reactor control dTc accumulated positively (absolute applied prior to accumulating)
    dTc_abs_accumulated: number<0 .. dTc_error_accumulated_max>,
    
    # Coolant absolute temperature as input to the simulation
    Tc: number<temp_min .. temp_max>,
    
    # Coolant absolute temperature referred from Tc_ini:  Tc = Tc_ini + Tc_delta
    Tc_delta: number<coolant_temp_min .. coolant_temp_max>,
    
    # Planned concentration (changes to equilibrium end value at the beginning of transition)
    C_plan: number<conc_min .. conc_max>,
    # Planned temperature (changes to equilibrium end value at the beginning of transition)
    T_plan: number<temp_min .. temp_max>,
}


# State which are used to train brain
# - set of states that the brain will have access to when deployed -
type ObservableState {
    # Concentration: Real-time reactor read
    Cr: number<conc_min .. conc_max>,
    # Temperature: Real-time reactor read
    Tr: number<temp_min .. temp_max>,

    # Concentration Error: Cr-Cref
    Cref_error: number<-5*conc_delta_max .. 5*conc_delta_max>,
    
    # Concentration: Target reference to follow
    #Cref: number<conc_min .. conc_max>,
    # Temperature: Target reference to follow
    #Tref: number<temp_min .. temp_max>,
    
    # Coolant absolute temperature as input to the simulation
    Tc: number<temp_min .. temp_max>,

}

# Action provided as output by policy and sent as
# input to the simulator
type SimAction {
    # Delta to be applied to initial coolant temp (absolutely, not per-iteration)
    # OPTION 1 (dTc) >> change_per_step_Tc_control: 1,
    Tc_control: number<-coolant_temp_deriv_limit .. coolant_temp_deriv_limit>
    ## OPTION 2 (Tc_delta) >> change_per_step_Tc_control: 2,
    #Tc_control: number<coolant_temp_min .. coolant_temp_max>
}

# Per-episode configuration that can be sent to the simulator.
# All iterations within an episode will use the same configuration.
type SimConfig {
    # Type of control to apply
    # Option 1 (dTc): Per-iteration increment control:  change_per_step_Tc_control = 1
    # Option 2 (Tc_delta): Absolute delta from initial Tc    change_per_step_Tc_control = 2
    change_per_step_Tc_control: number<1 .. 2 step 1>,

    # Scenario to be run - 4 scenarios: 1-based INT
    # > 1: Concentration transition -->  8.57 to 2.000 over [0, 10, 36, 45]
    # > 2: Concentration transition -->  8.57 to 2.000 over [0, 2, 28, 45]
    # > 3: Concentration transition -->  8.57 to 2.000 over [0, 10, 20, 45]
    # > 4: Concentration transition -->  8.57 to 1.000 over [0, 10, 36, 45]
    j_scenario: number<1 .. 4 step 1>,

    # Percentage of noise to include
    noise_percentage: number<0 .. 100>
}

function GetTerminal(S: SimState): Number.Bool {
    if S.Tr > temp_max-10 or S.Tr < temp_min+10 or S.Tc > coolant_temp_ini+20 or S.Tc < coolant_temp_ini-20{
        return true
    }
    else{
        return false
    }
}

# Reward definiton
function GetReward(S: SimState) {
    return 5 - Math.Abs(S.Cref_error)
}


# Define a concept graph with a single concept
graph (input: ObservableState) {
    concept ModifyConcentration(input): SimAction {
        curriculum {
            # The source of training for this concept is a simulator that
            #  - can be configured for each episode using fields defined in SimConfig,
            #  - accepts per-iteration actions defined in SimAction, and
            #  - outputs states with the fields defined in SimState.
            source simulator Simulator(Action: SimAction, Config: SimConfig): SimState {
            }

            training {
                # Limit episodes to 100 iterations instead of the default 1000.
                EpisodeIterationLimit: 90,
                NoProgressIterationLimit: 750000
            }
             
            algorithm {
                Algorithm: "SAC",
            }

            # The objective of training is expressed as 3 goals
            # (1) drive concentration close to reference
            # (2) avoid temperature going beyond limit
            # (3) avoid temperature changing too fast
            #  --> Goal not required when "change_per_step_Tc_control: 1" (doesn't harm either)
            #goal (State: SimState) {
            #    drive `Concentration Target`: 
            #        Math.Abs(State.Cref - State.Cr) in Goal.RangeBelow(0.6)
            #    avoid `Thermal Runaway`:
            #        Math.Abs(State.Tr) in Goal.RangeAbove(400)
            #    avoid `Rate Limit Tc`:
            #        Math.Abs(State.dTc_increment) in Goal.RangeAbove(coolant_temp_deriv_limit)
            #}

            terminal GetTerminal
            reward GetReward

            lesson `Follow Planned Concentration 1` {
                # Specify the configuration parameters that should be varied
                # from one episode to the next during this lesson.
                scenario {
                    # OPTION 1: dTc / OPTION 2: Tc_delta
                    change_per_step_Tc_control: 1,
                    # > 1: Concentration transition -->  8.57 to 2.000 over [0, 10, 36, 45]
                    # > 2: Concentration transition -->  8.57 to 2.000 over [0, 2, 28, 45]
                    # > 3: Concentration transition -->  8.57 to 2.000 over [0, 10, 20, 45]
                    # > 4: Concentration transition -->  8.57 to 1.000 over [0, 10, 36, 45]
                    j_scenario: 1,
                    # 1-100
                    noise_percentage: 0,
                }
            }
        }
    }
}

