function output = planTrajectories(world, predictions, scenario, cfg)
%PLANTRAJECTORIES Generate, score, and deterministically select candidates.
timer = tic;
lateralTargets = cfg.planner.lateralTargetsM;
targetSpeeds = cfg.planner.routeSpeedMps*cfg.planner.speedFractions;
count = numel(lateralTargets)*numel(targetSpeeds);
candidate = pathweaver.planning.generateCandidate(world.ego, 0, 0, cfg);
candidates = repmat(candidate, 1, count);
index = 0;
for i = 1:numel(targetSpeeds)
    for j = 1:numel(lateralTargets)
        index = index + 1;
        candidate = pathweaver.planning.generateCandidate(world.ego, ...
            lateralTargets(j), targetSpeeds(i), cfg);
        candidates(index) = pathweaver.planning.scoreCandidate( ...
            candidate, predictions, scenario, cfg);
    end
end
feasible = find([candidates.isFeasible]);
if isempty(feasible)
    selected = pathweaver.planning.generateCandidate(world.ego, ...
        world.ego.positionWorldM(2), 0, cfg);
    selected.isFeasible = false;
    selected.rejectionReason = "no feasible candidate";
    riskScore = inf;
    emergency = true;
else
    costs = [candidates(feasible).totalCost];
    terminalX = arrayfun(@(c) c.positionsWorldM(end,1), candidates(feasible));
    ordering = sortrows([costs(:), -terminalX(:), feasible(:)], [1 2 3]);
    selectedIndex = ordering(1,3);
    selected = candidates(selectedIndex);
    riskScore = selected.costTerms.dynamicRisk;
    emergency = false;
end
output = struct('selectedTrajectory', selected, ...
    'candidateTrajectories', candidates, 'planningLatencyS', toc(timer), ...
    'riskScore', riskScore, ...
    'minimumTtcS', pathweaver.planning.minimumTtc(world.ego, world.agents, cfg.horizon), ...
    'behaviorState', "CRUISE", 'emergencyFlag', emergency);
end
