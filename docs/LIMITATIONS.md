# Limitations

## Current repository state

- MATLAB is unavailable, so no executable prototype has been implemented.
- No test, demonstration, evaluation, planner latency, or safety result exists.
- Simulink, Stateflow, and toolbox licences cannot be queried.
- RoadRunner is unavailable and no native integration or fabricated asset exists.

## Intended v0.1 limitations

- Input is simulated actor ground truth, not implemented perception.
- Agent motion and constant-velocity prediction are simplified.
- No camera, LiDAR, radar, detection, or sensor fusion is implemented.
- Prediction is not learned and its risk score is not calibrated probability.
- Vehicle dynamics are planned as a kinematic bicycle approximation.
- The initial evaluation covers one scenario family and a small seed set.
- There is no real-road, hardware-in-the-loop, or road-deployment validation.
- Hybrid A*, model-predictive control, and production dynamics are out of scope.
- Native RoadRunner and Stateflow integration remain product-dependent.

PathWeaver must not be connected to or used to control a real vehicle.
