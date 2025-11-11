# TellurisLandingSimulation

Telluris Landing Simulation using MATLAB

## Overview
MATLAB simulation of when to fire 2nd stage engine. Force of rocket over time modeled to fit: https://estesrockets.com/products/f15-4-engines?srsltid=AfmBOopKaNhyDcEByrfRHtOX5CfD1Tsoa0LnAzC-BleU620qlZIWCuKe

## Limitations

The simulation currently does **not** account for:
- Aerodynamic drag
- Horizontal drift or wind effects
- Rocket tumbling or off-axis orientation
- Variable atmospheric conditions
- Engine gimbal control or thrust vectoring

### Timing Sensitivity

![Simulation Results](./graphs.png)

The optimization landscape (upper left) demonstrates the **critical importance of precise timing**. Small variations in engine start time (±0.1s) can result in impact velocity changes of several m/s. This sensitivity means:

1. **Precise timing is essential** - millisecond-level accuracy required
2. **Sensor accuracy matters** - altitude and velocity measurements must be reliable
3. **Unknown disturbances** (drag, drift, orientation) could significantly affect landing outcome
4. **Safety margins** should be incorporated for real-world applications
