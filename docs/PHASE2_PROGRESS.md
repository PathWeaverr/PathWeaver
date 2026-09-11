# BU SIH-26 Phase 2 release log

Start: 2026-09-11. Baseline checkout: bb913c0; worktree clean; no applicable
AGENTS.md found in the repository or ancestor folders. Preserve local authorship;
milestone commits only; no push.

Audit findings: TTC was time to closest approach with an enlarged proximity
threshold; collision geometry differed between planner and observer; only sample
points were checked; agent time led ego time by dt; global RNG was reset; crossing
onset depended on ego progress (unpaired encounters); replans repeated latency in
the per-tick log; selected stopped candidates could move laterally; completion
was not reflected in the terminal behaviour frame. Existing Stateflow tests cover
reset decisions only. Simulink subsystems are pass-through replay.

Baseline runtime: sandbox launch failed in Qt / CPU feature detection; approved
MATLAB batch outside sandbox succeeded. R2026a Update 5, all 16 original tests
passed. Original nominal run completed at 26.65 s without observed collision;
its old 0.1254 s proximity-based TTC must not be compared with the repaired TTC.
Evidence: artifacts/phase2_baseline.txt. Products: MATLAB, Simulink, Stateflow,
Automated Driving, Navigation, Vehicle Dynamics, Computer Vision, Sensor Fusion
and Tracking, Image Processing. Native RoadRunner is not part of this release.

Correctness work: three-disc covering vehicle footprint, continuous relative
segment collision checks, conservative road clearance, analytic finite-horizon
CV contact time; aligned world/prediction clocks; spatial quintic initial-pose
continuity; bounded emergency rollout and truthful infeasibility; per-call
latency excluding two warm-up plans; actual applied acceleration and jerk.
Verified correctness milestone: 31/31 tests passed, including Simulink replay
build/run and seven Stateflow reset decisions. Default completed at 24.25 s,
no contact, minimum conservative clearance 0.6272 m, minimum 3 s TTC 1.4957 s.
Evidence: artifacts/phase2_correctness_final.txt. Intermediate failed runs
exposed insufficient braking choices; retained in earlier diagnostic logs.
Explicit bounded braking now participates in selection; its jerk is a soft
comfort cost while all physical safety constraints remain enforced.

Preset milestone: nominal / challenging / emergency each ran twice identically
and completed without contact (24.25 / 25.25 / 25.20 s, seed 26037).
Three new integration tests passed. Physical crossing is clock-driven; random
position offsets use a local stream and are independent of planner execution.
Evidence: artifacts/phase2_presets.txt. Demo seed is a tuning case; evaluation
will use disjoint seeds 27001:27010, with every outcome retained.

Evaluation milestone: export regression passed, including timeout retention.
Exploratory 60-run batch (27001:27010, all presets, both modes): 60 completions,
zero collisions/timeouts/invalid runs. Risk-aware challenging mean completion
23.565 s vs baseline 24.800 s, with lower mean integrated jerk, but no collision
advantage and no consistent clearance improvement. This batch is marked dirty;
rerun from a clean release revision before publishing final evidence.
Outputs: artifacts/evaluation (raw runs, parameters, revision, CSV/MAT, plot).

Remaining: live controls and backup; sequence integration evidence; judge walkthrough;
final verification and commits. Update this record at each milestone.
