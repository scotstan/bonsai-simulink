# Building Energy Management

The process considered here is a thermal model of rooms in a building with a central heating and cooling system to provide comfort when the outdoor environment varies temperature, Toutdoor, throughout the day.  Comfort is characterized by meeting the set point temperature, Tset, for the inside of the room(s), but the controller should also consider minimizing the cost. Heating is four times as expensive as cooling, which reflects how typically energy bills are more expensive in Winter. Building energy management can get tough when using the same controller through different seasons and rooms with different heat losses due to number of windows.

<img src="img/building.png" alt="drawing" width="300"/>

This example shows how to use Project Bonsai’s Machine Teaching strategies to learn a controller to balance comfort and cost for heating and cooling rooms with various equivalent thermal resistances and outdoor environment. This sample is largely adapted from the [MathWorks' Thermal Model of A House](https://www.mathworks.com/help/simulink/slref/thermal-model-of-a-house.html)

<img src="img/model_integration.png" alt="drawing" width="800"/>

## Action

| Action | Discrete Value | Units |
|----------------------------|-------------------------------|-------------------------------|
| off | 3 | [-] |
| heater_blower | 2 | [-] |
| ac_blower | 1 | [-] |

## State

| State | Units |
|----------------------------|-------------------------------|
| Tset | [F] |
| Troom | [F] |
| Toutdoor | [F] |
| cost | [$] |

## Constraints

- Can only use AC or heater one at a time
- Tset is based on [energy.gov](https://www.energy.gov/energysaver/thermostats) recommended thermostat settings:
  - Summer: 78F during the day, 86F at night
  - Winter: 68F during the day, 60 at night
  - If Toutdoor > 73, follow the summer Tset, else follow the winter Tset.
- Troom within < 5 degrees F of set point

## Model Overview and Instructions

Please open the MATLAB livescript, `Building_Energy_Management.mlx`, for further descriptions and instructions for getting started with this sample.