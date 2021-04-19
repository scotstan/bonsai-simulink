inkling "2.0"

type SimState {
    observation1: number[3], 
    observation2: number[4],
    sim_reward: number
}

type ObservationState{
    observation1: number[3], 
    observation2: number[4],
}

# multiarm bandit actions. 
type SimAction{
    action_array1: number<0 .. 10>[3],
    action_array2: number<0 .. 10>[4],
}

type SimConfig {
    config_array3: number[2],
}

function Reward(sim_observation: SimState){
    return sim_observation.sim_reward
}

# irrelevant 
# function Terminal(sim_obervation: SimState){
#     return sim_obervation.sim_terminal
# }

simulator Simulator(action: SimAction, config: SimConfig): SimState {
}

graph (input: ObservationState): SimAction {

    concept optimize(input): SimAction {
        curriculum {
            algorithm {
                Algorithm: "PPO",
                #BatchSize: 8000,
                #PolicyLearningRate: 0.001
            }
            training {
                EpisodeIterationLimit: 5,
                NoProgressIterationLimit: 500000
            }
            source Simulator
            reward Reward

            lesson `learn 1` {
                scenario {
                    config_array3: number<3>[2],
                }
            }
        }
    }
    output optimize 
}
