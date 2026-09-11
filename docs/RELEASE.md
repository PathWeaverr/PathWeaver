# Phase 2 release verification

Baseline audited at `bb913c0`; implementation milestones are retained as local,
unsquashed conventional commits. The repository began clean. No native RoadRunner
or sensor integration was attempted.

## Current verification checkpoint

Corrected footprint/TTC, three physical presets, paired evaluation, live
diagnostics and the separate stateful Stateflow harness are implemented.
The complete suite passed **39/39 tests**, with **zero MATLAB Code Analyzer
findings**, at implementation revision a6f3390. The run included both model
builders, ordered Stateflow sequences, rendered playback invariance, paired
conditions and all default presets. The subsequent user MIT-licence commit
e70b0de is preserved. Clean-revision benchmark/video regeneration is the final
release gate.

Previously verified default risk-aware runs at seed 26037:

| Preset | Completion time | Minimum conservative clearance | Observed contact |
| --- | ---: | ---: | --- |
| nominal | 24.25 s | 0.6272 m | none |
| challenging | 25.25 s | 0.6618 m | none |
| emergency | 25.20 s | 0.6274 m | none |

The exploratory 60-run paired batch completed all runs without collision,
timeout or invalid outcomes. It was marked dirty and is not the final release
provenance. The final clean-revision batch will replace this checkpoint.

## Audit findings addressed

The old proximity/closest-approach proxy was not valid generic 2D TTC; old TTC
numbers must not be compared with the corrected metric. Geometry is now shared
and swept, world clocks align, actor timing is independent of ego motion, and
randomness is isolated. Intermediate failures exposed insufficient stopping
choices; bounded braking now participates in planning before infeasibility.
Collision checks were not weakened to obtain passing runs.

The Stateflow harness is tested on 186 ordered samples of state/reason/dwell
memory and seven reset cases (21 additional samples). These are defined-input
equivalence checks, not a Stateflow-controlled vehicle validation.

## Evidence locations

- `artifacts/phase2_full_tests.txt`: full-suite/analyzer transcript.
- `artifacts/phase2_test_results.mat`: machine-readable test results.
- `artifacts/release/evaluation/`: final per-run records, summary, plot and metadata.
- `artifacts/release/backup/nominal/`: backup video, snapshot and provenance.
- Earlier `artifacts/phase2_*.txt`: retained audit/regression diagnostics.

Generated evidence is not committed. Reproduction commands are in
[the demonstration guide](DEMO.md); metric definitions are in [Metrics](METRICS.md).

## Remaining work

Final gates: inspect clean-run exports and backup, recheck the updated media
script and Git state. After those gates, next priorities
are robustness/track-input validation, native RoadRunner/Simulink integration,
and sensor processing—not road deployment.
