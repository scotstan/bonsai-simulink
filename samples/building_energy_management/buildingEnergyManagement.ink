# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

inkling "2.0"

using Math
using Goal

# thresholds
const MaxDeviation = 5.0

type SimState {
    Tset: number<60 .. 86>,
    Troom1: number,
    Troom2: number,
    Troom3: number,
    n_rooms: number,
    Toutdoor: number,
    total_cost: number
}

type ObservableState {
    Tset: number,
    Troom_avg: number,
    Toutdoor: number,
    total_cost: number
}

type SimAction {
    command: number<cool=1.0, heat=2.0, off=3.0,>
}

type SimConfig {
    input_Toutdoor: number,
    input_nRooms: number,
    input_nWindowsRoom1: number,
    input_nWindowsRoom2: number,
    input_nWindowsRoom3: number,
}

function TransformState(State: SimState): ObservableState {
    return {
    Tset: State.Tset,
    Troom_avg: (State.Troom1 + State.Troom2 + State.Troom3) / State.n_rooms,
    Toutdoor: State.Toutdoor,
    total_cost: State.total_cost,
    }
}

function TempDiff(Tin:number, Tset:number) {
    return Math.Abs(Tin - Tset)
}

graph (input: ObservableState): SimAction {
    concept adjust(input): SimAction {
        curriculum {
            source simulator (action: SimAction, config: SimConfig): SimState {
            }

            state TransformState

            training {
                # Limit episodes to 288 iterations, which is 1 day (24 hours).
                EpisodeIterationLimit: 288,
                NoProgressIterationLimit: 600000
            }

            goal (State: SimState) {
                minimize `Temp Deviation`:
                    TempDiff(TransformState(State).Troom_avg, TransformState(State).Tset) in Goal.RangeBelow(MaxDeviation)
            }

            lesson adjust_easy {
                scenario {
                    input_Toutdoor: 60.0,
                    input_nRooms: 1,
                    input_nWindowsRoom1: 6,
                    input_nWindowsRoom2: 6,
                    input_nWindowsRoom3: 6,
                }
            }
            lesson adjust_medium {
                scenario {
                    input_Toutdoor: number<50.0 .. 70.0>,
                    input_nRooms: 1,
                    input_nWindowsRoom1: 6,
                    input_nWindowsRoom2: 6,
                    input_nWindowsRoom3: 6,
                }
            }
            lesson adjust_mediumhard {
                scenario {
                    input_Toutdoor: number<40.0 .. 80.0>,
                    input_nRooms: 1,
                    input_nWindowsRoom1: 6,
                    input_nWindowsRoom2: 6,
                    input_nWindowsRoom3: 6,
                }
            }
            lesson adjust_hard {
                scenario {
                    input_Toutdoor: number<30.0 .. 95.0>,
                    input_nRooms: 1,
                    input_nWindowsRoom1: 6,
                    input_nWindowsRoom2: 6,
                    input_nWindowsRoom3: 6,
                }
            }
            lesson adjust_hardest {
                scenario {
                    input_Toutdoor: number<25.0 .. 100.0>,
                    input_nRooms: 1,
                    input_nWindowsRoom1: 6,
                    input_nWindowsRoom2: 6,
                    input_nWindowsRoom3: 6,
                }
            }
        }
    }
    output adjust
}
