# Limitations

- Input is simulated actor ground truth, not implemented perception.
- Agent motion and constant-velocity prediction are simplified.
- No camera, LiDAR, radar, detection, or sensor fusion is implemented.
- Prediction is not learned; its risk score is not calibrated probability.
- Vehicle dynamics use a low-speed kinematic bicycle approximation.
- Evaluation covers one scenario family and ten paired seeds by default.
- Measured minimum TTC is low and warrants further safety-margin validation.
- Both modes completed current seeds, so no statistically meaningful superiority
  claim is supported by this small evaluation.
- Simulink is a runnable deterministic replay harness generated from the MATLAB
  closed loop; prediction/planning do not execute as native blocks.
- A seven-state Stateflow chart is generated and tested for direct decision
  equivalence. The closed-loop simulation still uses the MATLAB state machine,
  whose emergency-clear logic includes additional dwell-time memory.
- The RoadRunner API is installed, but RoadRunner is unsupported on macOS; no
  native project, scene, or integration is claimed.
- There is no real-road, hardware-in-the-loop, or deployment validation.
- Hybrid A*, MPC, and production-grade dynamics are out of scope.

PathWeaver must not control a real vehicle.
