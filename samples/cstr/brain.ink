# Copyright 2021 Microsoft Corporation
# This code is licensed under MIT license (see LICENSE for details)

# The process considered here is a Continuous Stirred Tank Reactor (CSTR)
# during transition from low to high conversion rate (high to low residual
# concentration). Because the chemical reaction is exothermic (produces heat),
# the reactor temperature must be controlled to prevent a thermal runaway. The
# control task is complicated by the fact that the process dynamics are
# nonlinear and transition from stable to unstable and back to stable as the
# conversion rate increases. The reactor dynamics are modeled in Simulink. The
# controlled variables (states) are the residual concentration Cr and the
# reactor temperature Tr, and the manipulated variable (action) is the
# temperature Tc of the coolant circulating in the reactor's cooling jacket.

# More details about the model are available at https://aka.ms/bonsai-chemicalprocessing

# The Chemical Processing example is part of the Project Bonsai Simulink Toolbox
# and can be downloaded from https://aka.ms/bonsai-toolbox

inkling "2.0"

using Math
using Number
using Goal

const SimulatorVisualizer = "https://scotstan.github.io/bonsai-viz-example/debug"

# Sim Period
const Ts = 0.5
# Coolant temperature derivative limit per minute
const coolant_temp_deriv_limit_per_min = 10
# Coolant temperature derivative limit
const coolant_temp_deriv_limit = Ts * coolant_temp_deriv_limit_per_min

# Limits for concentration
const conc_max = 12
const conc_min = 0.1

# Limits for reactor temperature
const temp_max = 800
const temp_min = 10

# Coolant temperature control dTc
const coolant_temp_ini = 297.9798
const coolant_temp_offset_min = temp_min - coolant_temp_ini
const coolant_temp_offset_max = temp_max - coolant_temp_ini

# State received from the simulator after each iteration
type SimState {
    # Concentration: Real-time reactor read
    Cr: number<conc_min .. conc_max>,
    # Temperature: Real-time reactor read
    Tr: number<temp_min .. temp_max>,

    # Concentration: Target reference to follow
    Cref: number<conc_min .. conc_max>,
    # Temperature: Target reference to follow
    Tref: number<temp_min .. temp_max>,

    # Coolant absolute temperature as input to the simulation
    Tc: number<temp_min .. temp_max>,

    # Coolant absolute temperature referred from TcEQ: Tc = TcEQ + dTc
    # dTc = integral(Tc_adjust)dt
    #dTc: number <coolant_temp_offset_min .. coolant_temp_offset_max>,
    # Coolant absolute temperature referred from TcEQ: Tc = TcEQ + dTc_rate_limited
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
    # > 1: Concentration transition --> 8.57 to 2.000 over [0, 0, 26, 45] (minutes) - 0 delay
    # > 2: Concentration transition --> 8.57 to 2.000 over [0, 10, 36, 45] (minutes) - original - 10 sec delay
    # > 3: Concentration transition --> 8.57 to 2.000 over [0, 20, 46, 45] (minutes) - 20 sec delay
    # > 4: Concentration transition --> 8.57 to 1.000 over [0, 30, 56, 45] (minutes) - 30 sec delay
    # > 5: Steady State --> 2
    Cref_signal: number<1 .. 5 step 1>,

    # Percentage of noise to include
    noise_percentage: number<0 .. 100>
}

simulator MySimulator(Action: number): ObservableState {
}

# Define a concept graph with a single concept
graph (input: ObservableState) {
    concept ModifyConcentration(input): SimAction {
        curriculum {

            algorithm {
                Algorithm: "SAC",
            }
            # The source of training for this concept is a simulator that
            # - can be configured for each episode using fields defined in SimConfig,
            # - accepts per-iteration actions defined in SimAction, and
            # - outputs states with the fields defined in SimState.
            source simulator Simulator(Action: SimAction, Config: SimConfig): SimState {
                # Automatically launch the simulator with this
                # registered package name.
                package "CSTR-20220106"

            }

            training {
                EpisodeIterationLimit: 90,
                NoProgressIterationLimit: 500000
            }
            # The objective of training is expressed as 2 goals
            # (1) drive concentration close to reference
            # (2) avoid temperature going beyond limit
            goal (State: SimState) {
                minimize `Concentration Reference`:
                    Math.Abs(State.Cref - State.Cr)
                    in Goal.RangeBelow(0.25)
                avoid `Thermal Runaway`:
                    Math.Abs(State.Tr)
                    in Goal.RangeAbove(400)
            }

            lesson `Follow Planned Concentration` {
                # Specify the configuration parameters that should be varied
                # from one episode to the next during this lesson.
                scenario {
                    # > 1: Concentration transition --> 8.57 to 2.000 over [0, 0, 26, 45] (minutes) - 0 delay
                    # > 2: Concentration transition --> 8.57 to 2.000 over [0, 10, 36, 45] (minutes) - original - 10 sec delay
                    # > 3: Concentration transition --> 8.57 to 2.000 over [0, 20, 46, 45] (minutes) - 20 sec delay
                    # > 4: Concentration transition --> 8.57 to 1.000 over [0, 30, 56, 45] (minutes) - 30 sec delay
                    # > 5: Steady State --> 8.57

                    Cref_signal: number<1>,
                    # 1-100
                    noise_percentage: number<0 .. 5>,
                }
            }
        }
    }

    concept SteadyState(input): SimAction {
        curriculum {
            algorithm {
                Algorithm: "SAC",
            }
            # The source of training for this concept is a simulator that
            # - can be configured for each episode using fields defined in SimConfig,
            # - accepts per-iteration actions defined in SimAction, and
            # - outputs states with the fields defined in SimState.
            source simulator Simulator(Action: SimAction, Config: SimConfig): SimState {
                # Automatically launch the simulator with this
                # registered package name.
                package "CSTR-20220106"
            }

            training {
                EpisodeIterationLimit: 90
            }
            # The objective of training is expressed as 2 goals
            # (1) drive concentration close to reference
            # (2) avoid temperature going beyond limit
            goal (State: SimState) {
                minimize `Concentration Reference`:
                    Math.Abs(State.Cref - State.Cr)
                    in Goal.RangeBelow(0.25)
                avoid `Thermal Runaway`:
                    Math.Abs(State.Tr)
                    in Goal.RangeAbove(400)
            }

            lesson `Lesson 1` {
                scenario {
                    # Scenario to be run - 4 scenarios: 1-based INT
                    # > 1: Concentration transition --> 8.57 to 2.000 over [0, 0, 26, 45] (minutes) - 0 delay
                    # > 2: Concentration transition --> 8.57 to 2.000 over [0, 10, 36, 45] (minutes) - original - 10 sec delay
                    # > 3: Concentration transition --> 8.57 to 2.000 over [0, 20, 46, 45] (minutes) - 20 sec delay
                    # > 4: Concentration transition --> 8.57 to 1.000 over [0, 30, 56, 45] (minutes) - 30 sec delay
                    # > 5: Steady State --> 8.57

                    Cref_signal: number<5>,
                    # 1-100
                    noise_percentage: number<0 .. 5>,
                }
            }
        }
    }

    output concept SelectStrategy(input): SimAction {
        select SteadyState
        select ModifyConcentration
        curriculum {
            source simulator Simulator(Action: SimAction, Config: SimConfig): SimState {
                package "CSTR-20220106"
            }

            training {
                EpisodeIterationLimit: 90,
                NoProgressIterationLimit: 500000
            }
            # The objective of training is expressed as 2 goals
            # (1) drive concentration close to reference
            # (2) avoid temperature going beyond limit

            goal (State: SimState) {
                minimize `Concentration Reference`:
                    Math.Abs(State.Cref - State.Cr)
                    in Goal.RangeBelow(0.25)
                avoid `Thermal Runaway`:
                    Math.Abs(State.Tr)
                    in Goal.RangeAbove(400)
            }

            lesson `Lesson 1` {
                scenario {
                    # > 1: Concentration transition --> 8.57 to 2.000 over [0, 10, 36, 45] (minutes) - 0
                    # > 2: Concentration transition --> 8.57 to 2.000 over [0, 0, 26, 45] (minutes) - 10 sec delay (original)
                    # > 3: Concentration transition --> 8.57 to 2.000 over [0, 10, 20, 45] (minutes) - 20 sec delay
                    # > 4: Concentration transition --> 8.57 to 1.000 over [0, 10, 36, 45] (minutes) - 30 sec delay
                    # > 5: Steady State --> 8.57

                    Cref_signal: number<2 .. 4 step 1>,
                    # 1-100
                    noise_percentage: number<0 .. 5>,
                }
            }
        }
    }


}


#! Visual authoring information
#! eyJ2ZXJzaW9uIjoiMi4wLjAiLCJ2aXN1YWxpemVycyI6eyJTaW11bGF0b3JWaXN1YWxpemVyIjoiaHR0cHM6Ly9zY290c3Rhbi5naXRodWIuaW8vYm9uc2FpLXZpei1leGFtcGxlL2NzdHIifSwiZ2xvYmFsIjp7InZpc3VhbGl6ZXJOYW1lcyI6WyJTaW11bGF0b3JWaXN1YWxpemVyIl19LCJjb25jZXB0cyI6eyJNb2RpZnlDb25jZW50cmF0aW9uIjp7InBvc2l0aW9uT3ZlcnJpZGUiOnsieCI6MjcwLjAwMDAzMjAwNjU3OTYsInkiOjg4fX0sIlN0ZWFkeVN0YXRlIjp7InBvc2l0aW9uT3ZlcnJpZGUiOnsieCI6Ni4wMDAwNzkyODcwOTcxNTEsInkiOjgxfX0sIlNlbGVjdFN0cmF0ZWd5Ijp7InBvc2l0aW9uT3ZlcnJpZGUiOnsieCI6MTc5LjAwMDcyNzI2ODgwMDU3LCJ5IjozNzV9fX19
