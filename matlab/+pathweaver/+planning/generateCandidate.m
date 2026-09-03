function candidate = generateCandidate(ego, lateralTargetM, targetSpeedMps, cfg)
%GENERATECANDIDATE Build a smooth trajectory in the road-aligned world frame.
t = (0:cfg.planDt:cfg.horizon)';
u = t/cfg.horizon;
blend3 = 3*u.^2 - 2*u.^3;
speeds = ego.speedMps + (targetSpeedMps - ego.speedMps).*blend3;
speeds = max(0, speeds);
x = ego.positionWorldM(1) + cumtrapz(t, speeds);
blend5 = 10*u.^3 - 15*u.^4 + 6*u.^5;
y = ego.positionWorldM(2) + (lateralTargetM - ego.positionWorldM(2)).*blend5;
positions = [x y];
dx = gradient(x, cfg.planDt);
dy = gradient(y, cfg.planDt);
headings = unwrap(atan2(dy, dx));
accelerations = gradient(speeds, cfg.planDt);
curvatures = gradient(headings, cfg.planDt)./max(speeds, 0.25);
costNames = {'dynamicRisk','staticObstacle','boundary','smoothness', ...
    'curvature','jerk','progress','routeDeviation','time'};
costTerms = cell2struct(num2cell(zeros(size(costNames))), costNames, 2);
candidate = struct('timestampsS', ego.timestampS + t, ...
    'positionsWorldM', positions, 'headingsRad', headings, ...
    'speedsMps', speeds, 'accelerationsMps2', accelerations, ...
    'curvaturesPerM', curvatures, 'costTerms', costTerms, ...
    'weightedCostTerms', costTerms, 'totalCost', inf, ...
    'isFeasible', true, 'rejectionReason', "");
end
