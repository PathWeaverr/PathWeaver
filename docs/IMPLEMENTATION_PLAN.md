# Implementation and verification plan

This plan is the deliverable required by the MATLAB-unavailable fallback. Every
stage has an evidence gate and should be committed independently using
`type(scope): short description`.

## Stage 0: restore the execution environment

1. Install or expose MATLAB on `PATH` and rerun `docs/ENVIRONMENT.md` checks.
2. Record exact versions, licences, and `which` results for every selected API.
3. Select a MATLAB-only polygon fallback if Automated Driving Toolbox is absent.
4. Create `setupPath.m` and deterministic configuration factories.

Gate: a batch MATLAB command loads configuration and validates all units.

## Stage 1: contracts, geometry, and scenario

Implement struct factories and validators for every contract in
`docs/ARCHITECTURE.md`. Geometry primitives cover point-in-polygon with ego
footprint inset, circle/polygon distance, footprint overlap, frame transforms,
angle wrapping, and interpolation.

Create a 150 m road with smooth irregular left/right boundaries around nominal
7 m width. Configure ego near x=5 m at 8 m/s, a pedestrian whose crossing motion
starts from a deterministic approach trigger, an oncoming two-wheeler, pothole,
and goal. Actor state updates are deterministic functions of time and prior
state; trigger state must be logged for replay.

Gate: deterministic snapshots match across two runs and geometry unit tests pass.
Commit: `feat(scenario): add deterministic village crossing`.

## Stage 2: prediction and risk

Implement the equations in `docs/ALGORITHMS.md`, class configuration for all
four required classes, PSD projection, fixed-footprint baseline, time alignment,
Mahalanobis risk, footprint overlap, and TTC.

Gate: analytic mean tests, eigenvalue tests, class ordering tests, monotonic risk
tests, and risk-aware/baseline distinction pass.
Commit: `feat(prediction): model class-conditioned uncertainty`.

## Stage 3: candidates and planner

Generate a deterministic Cartesian product of lateral endpoints and terminal
speeds. Implement trajectory derivatives, hard constraints, all nine named cost
terms, normalization, selection, and no-feasible-result semantics.

Gate: every candidate is internally coherent; infeasible reasons are stable;
cost decomposition sums to total within tolerance; the scenario exposes more
than one genuine candidate.
Commit: `feat(planning): implement risk-aware trajectory planner`.

## Stage 4: behaviour, control, and loop

Implement a pure MATLAB state transition function with hysteresis and structured
transition logs. Add pure pursuit, bounded longitudinal PID, emergency override,
and guarded bicycle integration. Assemble the closed loop in the specified order
and calculate collision/goal terminal states from geometry.

Gate: transition, emergency braking, bicycle, and short integration tests pass;
the default seed is genuinely collision-free or the defect is reported and fixed
without scenario-specific planner exceptions.
Commits: `feat(behavior): add driving state machine` and
`feat(control): close the vehicle control loop`.

## Stage 5: visualisation and demo

Render actual log/current structures only. Use a near-black axes background,
silver boundaries, cyan selected candidate, muted red rejected candidates, amber
warnings, predictions and covariance ellipses, and a fixed telemetry panel with
the mandatory `SIMULATED WORLD STATE` label. Video export uses `VideoWriter` only
when requested.

Gate: execute the demo headlessly and interactively, inspect a saved frame, and
verify displayed telemetry against its source log.
Commit: `feat(visualization): render planning telemetry`.

## Stage 6: evaluation and tests

Aggregate collision, completion, TTC, time, path length, measured `tic/toc`
latency, integrated absolute jerk, curvature, and emergency counts. Run identical
seed/config pairs in both modes and export MAT, CSV, and figure to ignored output.
Implement the full requested `matlab.unittest` matrix and a batch suite command.

Gate: 10–30 seeds finish, exports agree with in-memory values, and all tests pass.
Commits: `feat(evaluation): compare baseline and risk-aware modes` and
`test(core): verify simulation and planning behavior`.

## Stage 7: optional products

When Simulink is licensed, generate named subsystem boundaries and wrappers
around the same MATLAB algorithms. Compile and run a short deterministic model,
then compare outputs to the MATLAB loop. Add Stateflow only if programmatic chart
generation and transition equivalence are reliable.

When RoadRunner is installed and callable, follow `docs/ROADRUNNER_PORT.md`,
record its version/API proof, and commit only source assets.

Gate: models open, update, and execute without unresolved blocks; otherwise
document the exact blocker and retain MATLAB as the honest vertical slice.

## Planned test matrix

| Area | Checks |
|---|---|
| Geometry | frame transforms, boundaries, circle/polygon collision |
| Determinism | seed, actor trigger, replay outputs |
| Prediction | CV mean, growth ordering, PSD covariance |
| Risk | distance monotonicity, overlap/uncertainty response |
| Planning | constraints, finite signals, costs, selection |
| Behaviour | thresholds, hysteresis, terminals, transition log |
| Control | braking override, saturation, bicycle update |
| Integration | short closed loop, log schema, no NaNs |
| Products | conditional Simulink build/run when detected |

## Definition of done

Only change project status to runnable after all acceptance criteria are executed,
the demo/evaluation output is measured, warnings are reviewed, visuals inspected,
Git history audited for forbidden trailers, and limitations updated from actual
evidence.
