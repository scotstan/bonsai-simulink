# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

inkling "2.0"

using Math
using Goal

# thresholds
const MaxDeviation = 5.0

type SimState {
    Tset: number,
    Troom1: number,
    Troom2: number,
    Troom3: number,
    Toutdoor: number,
    total_cost: number
}

type ObservableState {
    Tset: number,
    Troom1: number,
    Toutdoor: number,
    total_cost: number
}

type SimAction {
    command: number<cool=1.0, heat=2.0, off=3.0,>
}

type SimConfig {
    input_Toutdoor: number
}

function TempDiff(Tin:number, Tset:number) {
    return Math.Abs(Tin - Tset)
}

graph (input: ObservableState): SimAction {
    concept adjust(input): SimAction {
        curriculum {
            source simulator (action: SimAction, config: SimConfig): ObservableState {
                # package "bem_final"
            }

            training {
                # Limit episodes to 288 iterations, which is 1 day (24 hours).
                EpisodeIterationLimit: 288,
                NoProgressIterationLimit: 600000
            }

            goal (State: ObservableState) {
                minimize `Temp Deviation`:
                    TempDiff(State.Troom1, State.Tset) in Goal.RangeBelow(MaxDeviation)
            }

            lesson adjust_easy {
                scenario {
                    input_Toutdoor: 60.0,
                }
            }
            lesson adjust_medium {
                scenario {
                    input_Toutdoor: number<50.0 .. 70.0>,
                }
            }
            lesson adjust_mediumhard {
                scenario {
                    input_Toutdoor: number<40.0 .. 80.0>,
                }
            }
            lesson adjust_hard {
                scenario {
                    input_Toutdoor: number<30.0 .. 95.0>,
                }
            }
            lesson adjust_hardest {
                scenario {
                    input_Toutdoor: number<25.0 .. 100.0>,
                }
            }
        }
    }
    output adjust
}
