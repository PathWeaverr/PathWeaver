# Algorithm design

This documents the implemented MATLAB algorithms. Configuration values remain
authoritative in `config/defaultConfig.m`.

## Prediction

For agent position `p_k`, velocity `v_k`, and future offset `tau`:

```text
mu(tau) = p_k + v_k tau
Sigma(tau) = projectPSD(Sigma_0 + Q_class tau + G_class tau^2)
```

`Q_class` and `G_class` are diagonal positive-semidefinite matrices in a frame
aligned with velocity, then rotated into the world frame. Pedestrian and animal
growth parameters must exceed two-wheeler and car parameters. A symmetric
eigendecomposition clamps eigenvalues to a small positive floor after rotation.
Baseline mode instead uses the same mean with a fixed deterministic footprint
and no uncertainty growth.

Constant velocity cannot predict intent, interaction, sudden turns, or crossing
onset before it appears in velocity. The expanding covariance expresses model
uncertainty; it is not a learned or calibrated forecast probability.

## Dynamic risk

At candidate position `q_i` and aligned prediction `(mu_i,Sigma_i)`, inflate the
covariance by an ellipse approximating both ego and agent footprints:

```text
S_i = Sigma_i + diag([rLong^2, rLat^2])
d_i^2 = (q_i - mu_i)' inv(S_i) (q_i - mu_i)
r_i = exp(-0.5 d_i^2) * uncertaintyScale(Sigma_i)
```

Use a Cholesky solve rather than explicit inversion. `uncertaintyScale` is a
bounded configurable function such as `1 + beta*sqrt(trace(Sigma_i))`. Integrate
risk over time with trapezoidal quadrature. This is a dimensionless risk score,
not collision probability. Reject definite footprint overlap and configurations
inside a configured Mahalanobis hard-risk contour.

Time-to-collision is estimated only for closing pairs using relative position
and velocity, clamped to the horizon; non-closing pairs report infinity. It is a
screening metric, not a substitute for time-aligned occupancy.

## Candidate generation

At each replan, express candidates in a local Frenet-like frame of the nominal
road direction without imposing a lane centre. Sample several lateral endpoints
inside the drivable polygon and several terminal speeds including progress,
cautious slowing, and controlled braking.

Lateral displacement uses a quintic polynomial satisfying initial lateral
position/velocity/acceleration and zero terminal lateral velocity/acceleration.
Longitudinal speed uses a cubic profile satisfying initial and target speed with
zero terminal acceleration. Integrate longitudinal speed, transform positions
to world coordinates, and derive heading and curvature with guarded finite
differences. Every candidate shares the prediction time grid.

Reject nonfinite candidates, points outside the drivable polygon after footprint
inset, static-obstacle overlap, definite dynamic overlap, excessive curvature,
steering, acceleration, deceleration, or jerk. The pothole is a hard forbidden
region plus a surrounding soft clearance cost.

## Planner cost

For feasible candidate `c`:

```text
J(c) = wDynamicRisk*CdynamicRisk
     + wStaticObstacle*CstaticObstacle
     + wBoundary*Cboundary
     + wSmoothness*Csmoothness
     + wCurvature*Ccurvature
     + wJerk*Cjerk
     + wProgress*Cprogress
     + wRouteDeviation*CrouteDeviation
     + wTime*Ctime
```

Each raw term, weight, and weighted term remains inspectable. Terms are
normalized against configuration scales. Progress is a cost such as remaining
forward distance, not a negative unbounded reward. Deterministic tie-breaking
uses candidate generation order after total cost and terminal progress.

Risk-aware and baseline modes share candidate generation, constraints,
controller, and scenario. Only prediction occupancy and the corresponding risk
calculation differ.

## Behaviour

Implemented states are `CRUISE`, `FOLLOW`, `YIELD`, `AVOID`, `EMERGENCY_BRAKE`,
`GOAL_REACHED`, and `COLLISION`. Collision and goal are terminal. Emergency is
entered when no feasible candidate exists, hard TTC is crossed, or required
deceleration exceeds the emergency threshold. It exits only after a larger TTC
and lower-risk threshold persist for a dwell period. Yield prioritizes crossing
vulnerable road users; avoid indicates a feasible lateral manoeuvre; follow
indicates constrained forward progress. All transitions log time, old/new state,
and measured reason. Threshold pairs and dwell periods prevent flicker.

## Controller and dynamics

Pure-pursuit-style steering selects a speed-dependent look-ahead point on the
selected trajectory:

```text
delta = atan2(2 L sin(alpha), lookahead)
aCmd = clamp(Kp*(vRef-v) + Ki*integralError, aMin, aMax)
```

Clamp steering and steering-rate; use anti-windup. Emergency overrides
longitudinal control with configured braking. A kinematic bicycle advances:

```text
xNext = x + v cos(psi) dt
yNext = y + v sin(psi) dt
psiNext = wrap(psi + v tan(delta)/L dt)
vNext = max(0, v + aCmd dt)
```

Inputs must be finite, wheelbase and look-ahead positive, and near-zero speed
handled without division. This is simplified low-speed planar motion, not
production vehicle dynamics or model-predictive control.
