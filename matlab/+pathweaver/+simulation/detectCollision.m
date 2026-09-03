function [collision, reason] = detectCollision(ego, scenario, cfg)
%DETECTCOLLISION Check ego footprint against agents, obstacle, and road edge.
egoRadius = cfg.ego.widthM/2;
collision = ~pathweaver.core.isDrivable(ego.positionWorldM, egoRadius, cfg.scenario);
reason = "road boundary";
if collision, return; end
obstacle = scenario.staticObstacles;
if pathweaver.core.circleOverlap(ego.positionWorldM, egoRadius, ...
        obstacle.positionWorldM, obstacle.geometry.radiusM)
    collision = true; reason = "static obstacle"; return
end
for k = 1:numel(scenario.agents)
    if pathweaver.core.circleOverlap(ego.positionWorldM, egoRadius, ...
            scenario.agents(k).positionWorldM, scenario.agents(k).collisionRadiusM)
        collision = true;
        reason = "agent " + string(scenario.agents(k).id);
        return
    end
end
reason = "";
end
