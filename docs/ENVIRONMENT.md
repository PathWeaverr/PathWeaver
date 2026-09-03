# Environment preflight

Preflight date: 2026-09-03

Host: macOS, timezone Asia/Kolkata

Workspace: `/Users/shivamkumar/Code/PathWeaver`

## Observed results

The repository directory was empty and was not inside another Git repository.
Git 2.50.1 (Apple Git-155) is available at `/usr/bin/git`.

MATLAB is not callable from the shell: `command -v matlab` returned no path.
No `MATLAB.app` or `RoadRunner.app` was found in `/Applications` or by macOS
Spotlight. Consequently, the required non-interactive MATLAB product, licence,
and API checks could not be executed.

| Product | Status | Evidence |
|---|---|---|
| MATLAB | unavailable | no executable/application found |
| Simulink | unknown/unusable | requires MATLAB product query |
| Automated Driving Toolbox | unknown/unusable | requires MATLAB product query |
| RoadRunner | unavailable | no executable/application found |
| Navigation Toolbox | unknown/unusable | requires MATLAB product query |
| Stateflow | unknown/unusable | requires MATLAB product query |
| Vehicle Dynamics Blockset | unknown/unusable | requires MATLAB product query |
| Computer Vision Toolbox | unknown/unusable | requires MATLAB product query |
| Sensor Fusion and Tracking Toolbox | unknown/unusable | requires MATLAB product query |

“Unknown/unusable” deliberately does not mean absent or licensed. It means the
current host cannot query or use the product without MATLAB.

## Required rerun after installation

Run the following without changing global configuration:

```sh
matlab -batch "disp(version); disp(ver); disp(license('inuse'));"
```

Then query licences and important APIs from MATLAB:

```matlab
products = {'Simulink','Automated_Driving_Toolbox','RoadRunner', ...
    'Navigation_Toolbox','Stateflow','Vehicle_Dynamics_Blockset', ...
    'Video_and_Image_Blockset','Sensor_Fusion_and_Tracking_Toolbox'};
for k = 1:numel(products)
    fprintf('%s: %d\n', products{k}, license('test', products{k}));
end

apis = {'drivingScenario','road','vehicle','pedestrian','trajectory', ...
    'birdsEyePlot','sim','new_system','sfroot','roadrunner'};
for k = 1:numel(apis)
    fprintf('%s -> %s\n', apis{k}, which(apis{k}));
end
```

Licence feature names vary by release. Validate ambiguous results against `ver`
and the locally installed MathWorks documentation before selecting APIs.

## Consequence

The requested executable prototype cannot be implemented or verified on this
host under the project's no-substitution policy. The repository therefore
contains structure, mathematical design, contracts, and an implementation plan
only. It does not claim a runnable demo, tests, metrics, Simulink model, or
RoadRunner integration.
