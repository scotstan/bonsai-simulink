# Pure MATLAB

This sample demonstrates how to create a simulation via MATLAB code without using a Simulink model.

The simulation itself is a very simple mathematical model that shows how to use states and actions that contain arrays.

## Action

| Action        | Value |
|---------------|-------|
| action_array1 | Array of numbers. These values will be multiplied by two an assigned to the *observation1* state. |
| action_array2 | Array of numbers. These values will be multiplied by three an assigned to the *observation2* state. |

## Configuration Parameters

| Config        | Value |
|---------------|-------|
| config_array3 | Array of numbers. These values will be added to the *sim_reward* state.|

## State

| State | Units |
|-------|-------|
| observation1 | Array of numbers. Receives the value of *action_array1* multiplied by two. |
| observation2 | Array of numbers. Receives the value of *action_array2* multiplied by three. |
| sim_reward | Number. Receives the sum of the numbers observation1, observation2, and config_array3. |
