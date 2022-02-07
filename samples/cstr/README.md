# Chemical Process Optimization

The process considered here is a Continuous Stirred Tank Reactor (CSTR)
during transition from low to high conversion rate (high to low residual
concentration). Because the chemical reaction is exothermic (produces
heat), the reactor temperature must be controlled to prevent a thermal
runaway. The control task is complicated by the fact that the process
dynamics are nonlinear and transition from stable to unstable and back
to stable as the conversion rate increases. The reactor dynamics are
modeled in Simulink. The controlled variables (states) are the residual
concentration  and the reactor temperature , and the manipulated
variable (action) is the temperature  of the coolant circulating in the
reactor's cooling jacket.

![CSTR Schematic](img/cstr_diagram.jpg)

This example shows how to use Project Bonsai's Machine Teaching
strategies to learn a controller for a chemical reactor transitioning
from low to high conversion rate. For background, see Seborg, D.E. et
al., "Process Dynamics and Control", 2nd Ed., 2004, Wiley, pp. 34-36.
This sample is largely adapted from the MathWorks':
[Gain scheduled control of a chemical reactor](https://www.mathworks.com/help/control/ug/gain-scheduled-control-of-a-chemical-reactor.html).

### Adapative PI Control

![Simulink PID](img/simulink_pid.png)

### Bonsai Brain Control
![Model Integration](img/simulink_bonsai.png)

## Actions (Manipulated Variables)

Bare minimum for the sim (all units are continuous):

| Action | Range      | Units    |
|--------|------------|----------|
| dTc    | [-20, 20]  | [Kelvin] |

Final set for **Bonsai training**:

- Performance improved when making the brain learn the per-timestep adjustment to apply to previous dTc.
- Thus, we maintained control to be dTc_adjust, and added an accumulator on sim side.

| Action     | Continuous Value | Units        |
| --------   | ------------     | ----------   |
| dTc_adjust | [-5, 5]*         | [Kelvin/min] |

*Note, given an additional rule that requires keeping dTc changes at no
more than 10 Kelvins/min, we forced dTc_adjust to be on the [-5, 5]
range (for Ts=0.5min)

## States (Control Variables)

Which matches the set of Observable States used for **bonsai training**

| State | Continuous Value | Units     |
| ----- | ---------------- | -----     |
| Cr    | [0.1, 12]        | [kmol/m3] |
| Tr    | [10, 800]        | [Kelvin]  |
| Tc    | [10, 800]        | [Kelvin]  |
| Cref  | [0.1, 12]        | [kmol/m3] |

> Note, .ink file defines ranges higher than the ones shown here. That
> is made in purpose since the brain will try to explore, and thus will
> hit extreme limits in doing so.

`Tref` was removed as observable state since brain to simplify brain's
training. With Bonsai's solution we don't need `Tref` to be able to drive
the concentration linearly from one point to the next.


## Constraints

* `Tc < 10` degrees / min
* `Tr < 400` to prevent thermal runaway

## Model Overview and Instructions

Please open the MATLAB livescript, `Chemical_Process_Optimization.mlx`,
for further descriptions and instructions for getting started with this
sample.

