# PathWeaver pitch-video production script

Target duration: 90–95 seconds

Format: 1920×1080, 30 fps, H.264

Project evidence clip: 26.7 seconds, generated at 10 fps

Default team label: **Team PathWeaver**

Replace the default team label in the generation command if your registered team
name is different.

## Generate everything before editing

From MATLAB, with the repository as the current folder:

```matlab
setupPath
recordPathWeaverEvidence(teamName="Team PathWeaver")
```

This generates the following ignored evidence under `artifacts/pitch/`:

- `01-opening.png`
- `02-problem.png`
- `03-core-idea.png`
- `04-architecture.png`
- `05-validation.png`
- `06-results.png`
- `07-closing.png`
- `pathweaver_demo.mp4`
- `simulink-model.png`
- `stateflow-behaviour.png`
- `stateflow-summary.png`
- the structured MAT result

Do not begin editing until MATLAB prints `completed=1 collision=0` and
`Evidence package complete`.

## Exact edit timeline and narration

| Edit time | Visual | Voice-over | On-screen label |
|---:|---|---|---|
| 00:00–00:06 | `01-opening.png`; slow 2% scale-in | “PathWeaver is a lane-agnostic, risk-aware autonomous-navigation prototype designed for unpredictable mixed traffic on unstructured Indian roads.” | Keep title card text visible |
| 00:06–00:16 | `02-problem.png`; reveal the four cards clockwise | “Indian roads may have missing lane markings, unpredictable crossings, mixed vehicles, potholes, and uncertain road edges. Fixed lanes and deterministic obstacle footprints miss this uncertainty.” | `THE ROAD DOES NOT BEHAVE LIKE A LANE` |
| 00:16–00:25 | `03-core-idea.png`; move a highlight from left to right | “Traditional planners avoid where an obstacle is. PathWeaver also plans around where unpredictable road users might be.” | `POSITION → PREDICTION → UNCERTAINTY → SAFER PATH` |
| 00:25–00:35 | `04-architecture.png`; highlight the left panel, then the right | “The working MATLAB core connects simulated world state, class-conditioned prediction, dynamic risk, behaviour, planning, control, and measured feedback. RoadRunner and synthetic sensor integration are the next platform phase.” | `IMPLEMENTED + VERIFIED` and `PLANNED INTEGRATION` |
| 00:35–01:02 | Entire `pathweaver_demo.mp4` | “Here, the ego vehicle approaches a crossing pedestrian and an oncoming two-wheeler. Predicted means and widening uncertainty ellipses feed time-aligned risk. Unsafe candidates are rejected in red, the selected path is cyan, and the controller yields, brakes, avoids the pothole, and continues to the goal.” | `MATLAB CLOSED-LOOP SIMULATION` / `SIMULATED WORLD-STATE INPUT` |
| 01:02–01:07 | `simulink-model.png`; crop to fill width | “The reproducible Simulink model compiles and runs as an integration replay of the same MATLAB closed loop.” | `RUNNABLE SIMULINK REPLAY INTEGRATION` |
| 01:07–01:12 | `stateflow-summary.png`; reveal the states, optionally cut to `stateflow-behaviour.png` for one second | “The seven-state Stateflow chart is generated programmatically and verified against the MATLAB decision logic.” | `STATEFLOW DECISION EQUIVALENCE VERIFIED` |
| 01:12–01:20 | `05-validation.png`; highlight implemented then planned rows | “Village crossing is implemented. Intersections, highway merges, dense markets, and cattle crossings define the next validation set.” | Preserve each `IMPLEMENTED`/`PLANNED` tag |
| 01:20–01:29 | `06-results.png`; animate the four measured cards | “Across ten paired seeds, both modes completed every run without collision. These are preliminary simulation measurements, not road-deployment validation.” | `MEASURED V0.1 RESULTS` |
| 01:29–01:35 | `07-closing.png`; hold for the final two seconds | “PathWeaver does not merely plan around where road users are. It plans around where they might be.” | Closing card |

## Recording and editing order

1. Confirm the registered team name and regenerate the package if necessary.
2. Watch `pathweaver_demo.mp4` from beginning to end. Reject the take if the
   summary does not say completion without collision.
3. Import the seven numbered slides first; their names already define order.
4. Insert the entire demonstration at 00:35 without changing playback speed.
5. Insert the Simulink and Stateflow images immediately afterward.
6. Record voice-over in a quiet room after the rough cut exists. Aim for calm,
   technical delivery rather than advertisement pacing.
7. Add the mandatory labels exactly as written in the timeline.
8. Keep music at least 18 dB below narration and avoid decorative transitions;
   use cuts or 6–10-frame dissolves.
9. Export once, watch the complete render with headphones, and check that every
   `PLANNED` label stays visible long enough to read.
10. Export the final H.264 file at 1080p, 30 fps, 12–20 Mbit/s.

## Claims checklist before submission

Say **implemented** only for:

- MATLAB closed-loop scenario, prediction, risk, planning, behaviour, control;
- expanding class-conditioned uncertainty;
- candidate constraints and cost selection;
- actual metrics and deterministic evaluation;
- Simulink replay-model execution;
- Stateflow decision equivalence for tested direct transitions.

Say **planned** for:

- RoadRunner scene or feedback;
- camera, LiDAR, and radar processing;
- detection, tracking, and sensor fusion;
- native block-by-block Simulink planner execution;
- the four additional scenario families.

Never show stock or generated road footage with a label implying it came from
PathWeaver perception. RoadRunner is unavailable on macOS according to MathWorks;
native RoadRunner evidence must be captured later on supported Windows/Linux.

## Optional live presentation sequence

If judges request a live demonstration:

```matlab
result = runPathWeaverDemo;
```

Then run:

```matlab
results = runPathWeaverEvaluation;
testResults = runPathWeaverTests;
```

Open generated model evidence only after the live simulation completes:

```matlab
buildPathWeaverModel
buildPathWeaverStateflowModel
open_system('pathweaver_v0')
open_system('pathweaver_behavior/PathWeaver Behaviour')
```
