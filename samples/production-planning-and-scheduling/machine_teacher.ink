inkling "2.0"

using Math
using Goal

type SimState {
    num_bad_parts: number,
    num_good_parts: number,
    numInspectWorkersUsed: number,
    numMfgWorkersUsed: number,
}

type ObservableState {
    num_bad_parts: number,
    num_good_parts: number,
    numInspectWorkersUsed: number,
    numMfgWorkersUsed: number,
}

type SimAction {
    product_variant_order: number<1 .. 40 step 1>[200],
}

type SimConfig {
    discard_rate: number<0.04 .. 0.1>,
    numMfgWorkers: number<2, 3,>,
    numInspectWorkers: number<2, 3,>,
}

simulator JobScheduling(action: SimAction, config: SimConfig): SimState {
}

graph (input: ObservableState): SimAction {
    concept Scheduling (input): SimAction{
        curriculum {
            source JobScheduling

            training {
                EpisodeIterationLimit: 1,
                NoProgressIterationLimit: 750000,
            }

            goal (s: SimState) {
                maximize Throughput:
                    s.num_good_parts in Goal.RangeAbove(240)
            }

            lesson Baseline {
                scenario {
                    discard_rate: 0.04,
                    numMfgWorkers: 3,
                    numInspectWorkers: 3,
                }
            }
        }
    }
}