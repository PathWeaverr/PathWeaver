function scenario = advanceAgents(scenario, ego, dt, cfg)
%ADVANCEAGENTS Advance deterministic agents without teleportation.
pedIndex = find([scenario.agents.id] == cfg.scenario.pedestrian.id, 1);
if ~scenario.pedestrianTriggered && ego.positionWorldM(1) >= ...
        cfg.scenario.pedestrian.triggerEgoXM
    scenario.pedestrianTriggered = true;
    scenario.agents(pedIndex).velocityWorldMps = ...
        [0 cfg.scenario.pedestrian.crossingSpeedMps];
end
for k = 1:numel(scenario.agents)
    scenario.agents(k).positionWorldM = scenario.agents(k).positionWorldM + ...
        scenario.agents(k).velocityWorldMps*dt;
    scenario.agents(k).timestampS = scenario.timeS + dt;
end
scenario.timeS = scenario.timeS + dt;
end
