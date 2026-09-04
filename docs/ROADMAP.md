# Roadmap

## Phase 0 — executable foundation (completed for v0.1)

MATLAB provisioning, API preflight, the vertical slice, deterministic replay,
tests, visuals, metrics, and a Simulink replay harness are complete.

## Phase 1 — MathWorks integration

Replace the runnable Simulink replay harness with native subsystem execution.
Extend the generated Stateflow chart from direct-decision equivalence to full
sequence/dwell equivalence. Integrate RoadRunner on supported Windows/Linux.

## Phase 2 — scenario breadth and robustness

Add animals, parked vehicles, occlusion-aware uncertainty, road-width variants,
adversarial crossing onset, noisy/delayed tracks, Monte Carlo evaluation, and
regression thresholds based on measured distributions.

## Phase 3 — perception boundary

Introduce timestamped detection and tracking adapters for recorded or simulated
sensors, calibrated uncertainty, track lifecycle management, and dataset-backed
evaluation. Do not describe this as sensor fusion until it is implemented.

## Phase 4 — higher-fidelity autonomy research

Evaluate interaction-aware prediction, vehicle dynamics, actuator delay,
optimization-based planning/control, safety monitors, SIL/HIL, formal scenario
coverage, and controlled proving-ground validation under appropriate governance.
