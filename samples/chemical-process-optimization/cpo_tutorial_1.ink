###

# MSFT Bonsai 
# Copyright 2021 Microsoft
# This code is licensed under MIT license (see LICENSE for details)

# CPO Tutorial 1 - Chemical Process Optimization
# This introductory sample demonstrates how to teach a policy for 
# controlling a chemical process, specifically a CSTR, Continuous
# Stirred Tank Reactor
#
# Note, in this first tutorial, no noise is introduced for learning

###

inkling "2.0"

using Math
using Number
using Goal

# Sim Period
const Ts = 0.5
# Coolant temperature derivative limit per minute
const coolant_temp_deriv_limit_per_min = 10
# Coolant temperature derivative limit
const coolant_temp_deriv_limit = Ts*coolant_temp_deriv_limit_per_min

# Limits for concentration
const conc_max = 10
const conc_min = 0.5

# Limits for temperature
const temp_max = 500
const temp_min = 40

# Coolant temperature control dTc
const coolant_temp_ini = 297.9798
const coolant_temp_min = temp_min-coolant_temp_ini
const coolant_temp_max = temp_max-coolant_temp_ini

# State received from the simulator after each iteration
type SimState {
    # Concentration: Real-time reactor read
    Cr: number<conc_min .. conc_max>,
    # Temperature: Real-time reactor read
    Tr: number<temp_min .. temp_max>,
    
    # Concentration: Real-time reactor read without any potential noise
    Cr_no_noise: number<conc_min .. conc_max>,
    # Temperature: Real-time reactor read without any potential noise
    Tr_no_noise: number<temp_min .. temp_max>,

    # Concentration: Target reference to follow
    Cref: number<conc_min .. conc_max>,
    # Temperature: Target reference to follow
    Tref: number<temp_min .. temp_max>,

    # Coolant absolute temperature as input to the simulation
    Tc: number<temp_min .. temp_max>,
    
    # Coolant absolute temperature referred from TcEQ:  Tc = TcEQ + dTc
    # dTc = integral(Tc_adjust)dt
    dTc: number<coolant_temp_min .. coolant_temp_max>,
    # Coolant absolute temperature referred from TcEQ:  Tc = TcEQ + dTc_rate_limited
    dTc_rate_limited: number<coolant_temp_min .. coolant_temp_max>,
    
    # TcEQ(1), relating to Tc = TcEQ + dTc
    Tc_eq: number<290 .. 310>,
    # dTC delayed 1 timestep
    dTc_prev: number<coolant_temp_min .. coolant_temp_max>,
}


# State which are used to train brain
# - set of states that the brain will have access to when deployed -
type ObservableState {
    # Concentration: Real-time reactor read
    Cr: number<conc_min .. conc_max>,

    # Temperature: Real-time reactor read
    Tr: number<temp_min .. temp_max>,

    # Concentration: Target reference to follow
    Cref: number<conc_min .. conc_max>,
    
    # Coolant absolute temperature as input to the simulation
    Tc: number<temp_min .. temp_max>,
}

# Action provided as output by policy and sent as
# input to the simulator
type SimAction {
    # Delta to be applied to initial coolant temp (absolutely, not per-iteration)
    Tc_adjust: number<-coolant_temp_deriv_limit .. coolant_temp_deriv_limit>
}

# Per-episode configuration that can be sent to the simulator.
# All iterations within an episode will use the same configuration.
type SimConfig {
    # Scenario to be run - 4 scenarios: 1-based INT
    # > 1: Concentration transition -->  8.57 to 2.000 over [0, 10, 36, 45] (minutes)
    # > 2: Concentration transition -->  8.57 to 2.000 over [0, 2, 28, 45] (minutes)
    # > 3: Concentration transition -->  8.57 to 2.000 over [0, 10, 20, 45] (minutes)
    # > 4: Concentration transition -->  8.57 to 1.000 over [0, 10, 36, 45] (minutes)
    Cref_signal: number<1 .. 4 step 1>,

    # Percentage of noise to include
    noise_percentage: number<0 .. 100>
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
                # Limit episodes to 90 iterations instead of the default 1000.
                EpisodeIterationLimit: 90,
                NoProgressIterationLimit: 750000
            }
             
            algorithm {
                Algorithm: "SAC",
            }

            # The objective of training is expressed as 3 goals
            # (1) drive concentration close to reference
            # (2) avoid temperature going beyond limit
            # (3) avoid temperature changing too fast (accomplished with max action value)
            goal (State: SimState) {
                minimize `Concentration Reference`: 
                    Math.Abs(State.Cref - State.Cr) in Goal.RangeBelow(0.25)
                avoid `Thermal Runaway`:
                    Math.Abs(State.Tr) in Goal.RangeAbove(400)
            }

            lesson `Follow Planned Concentration` {
                # Specify the configuration parameters that should be varied
                # from one episode to the next during this lesson.
                scenario {
                    # > 1: Concentration transition -->  8.57 to 2.000 over [0, 10, 36, 45] (minutes)
                    # > 2: Concentration transition -->  8.57 to 2.000 over [0, 2, 28, 45] (minutes)
                    # > 3: Concentration transition -->  8.57 to 2.000 over [0, 10, 20, 45] (minutes)
                    # > 4: Concentration transition -->  8.57 to 1.000 over [0, 10, 36, 45] (minutes)
                    Cref_signal: 1,
                    # 1-100
                    noise_percentage: 0,
                }
            }
        }
    }
}
