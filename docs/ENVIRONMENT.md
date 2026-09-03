# Environment preflight

Preflight date: 2026-09-03

Host: Apple-silicon (`arm64`) macOS 26.5.1, timezone Asia/Kolkata

MATLAB was installed using the official MathWorks Package Manager at:

```text
/Users/shivamkumar/Applications/MathWorks/R2026a.app
```

Batch launch and online licensing were verified. MATLAB reports
`26.1.0.3346908 (R2026a) Update 5`.

## Installed products

All report version 26.1:

- MATLAB
- Simulink
- Automated Driving Toolbox
- Navigation Toolbox
- Stateflow
- Vehicle Dynamics Blockset
- Computer Vision Toolbox
- Sensor Fusion and Tracking Toolbox
- Image Processing Toolbox (dependency)

Licence probes returned true for MATLAB, Simulink, Automated Driving Toolbox,
Navigation Toolbox, Stateflow, and Vehicle Dynamics Blockset. The Computer Vision
feature-name probe returned false despite installation; the Sensor Fusion name
exceeded the `license` function's length limit. Neither is used by the prototype.

## API checks

| API | Observed result |
|---|---|
| `drivingScenario` | found in shared driving-scenario package |
| `road`, `vehicle` | found as `drivingScenario` methods |
| `pedestrian`, `trajectory` | no standalone function found |
| `birdsEyePlot` | found in Automated Driving Toolbox |
| `sim`, `new_system` | found as Simulink builtins |
| `sfroot` | found in Stateflow |
| `roadrunner` | MATLAB API found |

No RoadRunner application bundle exists in the MathWorks installation or
`/Applications`; the API alone cannot provide native integration.

## Verification command

```sh
/Users/shivamkumar/Applications/MathWorks/R2026a.app/bin/matlab -batch \
  "disp(version); disp(ver); disp(license('inuse'));"
```

Installed toolbox presence does not imply that a capability is claimed.
