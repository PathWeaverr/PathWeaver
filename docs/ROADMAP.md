# Roadmap

## Phase 0 — executable foundation (completed for v0.1)

MATLAB provisioning, API preflight, the vertical slice, deterministic replay,
tests, visuals, metrics, and a Simulink replay harness are complete.

## Phase 1 — MathWorks integration

Add a reproducibly generated, runnable Simulink model sharing the tested MATLAB
algorithms. Add Stateflow only with equivalence tests. Integrate RoadRunner only
after supported native APIs are detected and exercised.

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
