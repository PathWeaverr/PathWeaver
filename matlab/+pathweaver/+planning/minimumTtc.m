function ttcS = minimumTtc(ego, agents, horizonS)
%MINIMUMTTC Conservative point-pair constant-velocity time to closest approach.
egoVelocity = ego.speedMps*[cos(ego.headingRad) sin(ego.headingRad)];
ttcS = inf;
for k = 1:numel(agents)
    relativePosition = agents(k).positionWorldM - ego.positionWorldM;
    relativeVelocity = agents(k).velocityWorldMps - egoVelocity;
    speedSquared = dot(relativeVelocity, relativeVelocity);
    if speedSquared < 1e-9 || dot(relativePosition, relativeVelocity) >= 0
        continue
    end
    closestTime = min(horizonS, max(0, -dot(relativePosition, relativeVelocity)/speedSquared));
    combinedRadius = hypot(2.1, 0.9)*0.72 + agents(k).collisionRadiusM;
    closestDistance = norm(relativePosition + closestTime*relativeVelocity);
    if closestDistance <= combinedRadius + 1.0
        ttcS = min(ttcS, closestTime);
    end
end
end
