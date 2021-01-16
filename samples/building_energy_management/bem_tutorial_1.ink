# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

inkling "2.0"

using Math
using Goal

# thresholds
const MaxDeviation = 5.0

# This is the state received from the simulator after each iteration.
type SimState {
    Tset: number<60 .. 86>,
    Troom1: number<-20 .. 120>,
    Troom2: number<-20 .. 120>,
    Troom3: number<-20 .. 120>,
    n_rooms: number<1,2,3>,
    Toutdoor: number<-20 .. 120>,
    total_cost: number<0 .. 100>,
    step_cost: number<0 .. 0.5>,
}

# This is the subset of the simulator state that is observable by the AI.
type ObservableState {
    Tset: number<60 .. 86>,
    Troom1: number<-20 .. 120>,
    Toutdoor: number<-20 .. 120>,
    step_cost: number<0 .. 0.5>,
}

# This is the action that is sent to the simulator.
type SimAction {
    command: number<cool=1.0, heat=2.0, off=3.0,>
}

type SimConfig {
    # Average outdoor temperature for the day
    input_Toutdoor: number<25.0 .. 100.0>,
    
    # Number of rooms in building
    input_nRooms: number<1,2,3>,
    
    # Number of windows in building
    input_nWindowsRoom1: number<0 .. 12>,
    input_nWindowsRoom2: number<0 .. 12>,
    input_nWindowsRoom3: number<0 .. 12>,
}

function TempDiff(Tin: number, Tset: number) {
    return Math.Abs(Tin - Tset)
}

graph (input: ObservableState): SimAction {
    concept CostperComfort(input): SimAction {
        curriculum {
            source simulator (action: SimAction, config: SimConfig): SimState {
            }

            training {
                # Limit episodes to 288 iterations, which is 1 day (24 hours).
                EpisodeIterationLimit: 288,
                NoProgressIterationLimit: 500000
            }

            goal (State: SimState) {
                minimize `Temp Deviation`:
                    TempDiff(State.Troom1, State.Tset) in Goal.RangeBelow(MaxDeviation)
                minimize Cost:
                    State.step_cost in Goal.RangeBelow(0)
            }

            lesson `Comfort and Cost` {
                scenario {
                    input_Toutdoor: number<25.0 .. 100.0>,
                    input_nRooms: 1,
                    input_nWindowsRoom1: 6,
                }
            }

        }
    }
}
