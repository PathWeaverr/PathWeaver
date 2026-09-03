function [command, state] = trackTrajectory(ego, trajectory, emergency, state, cfg)
%TRACKTRAJECTORY Pure-pursuit lateral and bounded PI longitudinal control.
lookahead = cfg.control.lookaheadBaseM + cfg.control.lookaheadGainS*ego.speedMps;
distances = vecnorm(trajectory.positionsWorldM - ego.positionWorldM, 2, 2);
targetIndex = find(distances >= lookahead, 1);
if isempty(targetIndex), targetIndex = size(trajectory.positionsWorldM, 1); end
target = trajectory.positionsWorldM(targetIndex,:);
deltaWorld = target - ego.positionWorldM;
targetAngle = atan2(deltaWorld(2), deltaWorld(1));
alpha = pathweaver.core.wrapAngle(targetAngle - ego.headingRad);
steering = atan2(2*cfg.ego.wheelbaseM*sin(alpha), max(lookahead, 0.5));
steering = max(-cfg.ego.maxSteeringRad, min(cfg.ego.maxSteeringRad, steering));
maxChange = cfg.ego.maxSteeringRateRadps*cfg.dt;
steering = max(state.previousSteeringRad-maxChange, ...
    min(state.previousSteeringRad+maxChange, steering));

referenceSpeed = trajectory.speedsMps(min(targetIndex, numel(trajectory.speedsMps)));
error = referenceSpeed - ego.speedMps;
state.integralSpeedError = max(-cfg.control.integralLimit, ...
    min(cfg.control.integralLimit, state.integralSpeedError + error*cfg.dt));
acceleration = cfg.control.speedKp*error + ...
    cfg.control.speedKi*state.integralSpeedError;
if emergency
    acceleration = cfg.ego.minAccelerationMps2;
    state.integralSpeedError = 0;
end
acceleration = max(cfg.ego.minAccelerationMps2, ...
    min(cfg.ego.maxAccelerationMps2, acceleration));
state.previousSteeringRad = steering;
command = struct('steeringRad', steering, 'accelerationMps2', acceleration, ...
    'referenceSpeedMps', referenceSpeed, 'lookaheadM', lookahead);
end
