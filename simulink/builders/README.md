# Simulink integration

Run `buildPathWeaverModel` to reproducibly generate, compile, and run
`simulink/models/pathweaver_v0.slx`. The model is a deterministic replay harness:
the tested MATLAB closed loop generates its input, and visible pass-through
subsystems expose architectural boundaries and logged signals. It is not native
block-by-block execution of prediction or planning.
