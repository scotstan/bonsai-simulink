% Copyright (c) Microsoft Corporation.
% Licensed under the MIT License.

% Simple simulation class that demonstrates reciving config and actions,
% reset, step, and returning state.

classdef Simulation < handle
    properties (Constant)
        max_array_size = 20;
    end
    
    properties (Access = private)
        observation1;
        observation2;
        config_array3;
        sim_reward;
    end
        
    methods (Access = public)
        function reset(obj, config)
            % Reset simulation to initial state based on config.
            % Note: Fields of the config must match those set as
            % configSchema in bonsaiConfig.m.
            obj.observation1 = zeros(obj.max_array_size, 1);
            obj.observation2 = zeros(obj.max_array_size, 1);
            obj.sim_reward = 0;
            obj.config_array3 = config.config_array3;
        end
        
        function halted = step(obj, action)
            % Apply action to current state.
            % Return false to continue or true to halt.
            % Note: Fields of the action must match those set as
            % actionSchema in bonsaiConfig.m.
            
            % This simple simulation assigns the observation states to the
            % value of the action arrays multipled by 2 and 3. Then is
            % assigns the sim_reward state to the sum of the config and
            % observation values.
            obj.observation1 = action.action_array1 * 2;
            obj.observation2 = action.action_array2 * 3;
            obj.sim_reward = sum(obj.observation1) + sum(obj.observation2) + sum(obj.config_array3);
            halted = false;
        end
        
        function state = getState(obj)
            % Return current state.
            % Note: Elements of the returned state must correspond to
            % those set as stateSchema in bonsaiConfig.m.
            state = {obj.observation1 obj.observation2 obj.sim_reward};
        end
    end
end
