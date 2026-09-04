# Implementation record and next gates

## Completed and executed

1. MATLAB R2026a and relevant products installed, licensed, and inventoried.
2. Contracts, geometry, deterministic scenario, and world-state adapter built.
3. Class-conditioned CV prediction, PSD uncertainty, and baseline mode built.
4. Time-indexed risk, hard constraints, candidate generation, and nine-term cost
   decomposition built.
5. Behaviour, controller, bicycle motion, metrics, replay, and terminal handling
   assembled into the closed loop.
6. Technical visualisation executed and inspected from a generated frame.
7. Ten paired seeds evaluated in baseline and risk-aware modes.
8. Fifteen unit/integration tests passed.
9. Simulink replay model generated, updated, and run programmatically.
10. Seven-state Stateflow chart generated and checked against MATLAB decisions.
11. Reproducible pitch frames, MP4 evidence capture, and edit script generated.

## Remaining product-dependent work

- Move to supported Windows/Linux, install RoadRunner, and follow
  `ROADRUNNER_PORT.md`; RoadRunner is unavailable on macOS.
- Replace the Simulink replay harness with native subsystem execution only after
  numerical equivalence tests are in place.
- Move closed-loop dwell-time memory into Stateflow after sequence-level
  equivalence tests; direct decision equivalence is already verified.

## Next engineering gates

1. Add crossing-onset, lateral-speed, and road-width perturbations, then evaluate
   hundreds of paired seeds with explicit regression thresholds.
2. Improve TTC geometry and safety margins; current minimum-TTC values are low.
3. Introduce delayed/noisy track inputs at the world-state adapter and verify
   graceful degradation before adding any sensor-processing claim.

Every new stage must retain measured evidence, clean milestone commits, and the
scope-honesty statements in README and limitations.
