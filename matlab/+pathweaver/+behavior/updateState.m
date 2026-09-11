function [state, transition] = updateState(state, planner, world, scenario, collision, cfg)
%UPDATESTATE Select behaviour from measured conditions with hysteresis.
oldName = state.name;
reason = "conditions nominal";
goalDistance = norm(world.ego.positionWorldM - scenario.goalPositionWorldM);
nearestDistance = inf;
for k = 1:numel(world.agents)
    nearestDistance = min(nearestDistance, norm( ...
        world.agents(k).positionWorldM - world.ego.positionWorldM));
end
if oldName=="COLLISION" || oldName=="GOAL_REACHED"
    newName=oldName; reason="terminal state retained";
elseif collision
    newName = "COLLISION"; reason = "footprint collision detected";
elseif goalDistance <= cfg.goalToleranceM
    newName = "GOAL_REACHED"; reason = "ego entered goal region";
elseif planner.emergencyFlag || isnan(planner.minimumTtcS) || planner.minimumTtcS < cfg.behavior.emergencyTtcS
    newName = "EMERGENCY_BRAKE";
    if ~planner.selectedTrajectory.isFeasible
        reason="no feasible candidate; braking, safety not guaranteed";
    elseif planner.emergencyFlag
        reason="bounded braking selected by planner";
    elseif isnan(planner.minimumTtcS)
        reason="TTC unavailable; fail-closed braking";
    else
        reason="predicted footprint contact below emergency threshold";
    end
elseif planner.minimumTtcS < cfg.behavior.yieldTtcS || ...
        planner.riskScore > cfg.behavior.riskYield
    newName = "YIELD"; reason = "crossing risk or TTC threshold";
elseif abs(planner.selectedTrajectory.positionsWorldM(end,2) - ...
        world.ego.positionWorldM(2)) > 0.6
    newName = "AVOID"; reason = "selected lateral avoidance trajectory";
elseif nearestDistance < cfg.behavior.followDistanceM
    newName = "FOLLOW"; reason = "nearby road user limits progress";
else
    newName = "CRUISE";
end

if oldName == "EMERGENCY_BRAKE" && newName ~= "COLLISION" && ...
        newName ~= "GOAL_REACHED"
    clearNow = planner.minimumTtcS > cfg.behavior.yieldTtcS + 0.8 && ...
        planner.riskScore < cfg.behavior.riskClear && ~planner.emergencyFlag;
    if clearNow
        if isnan(state.clearSinceS), state.clearSinceS = world.timestampS; end
        if world.timestampS - state.clearSinceS < cfg.behavior.clearDwellS
            newName = oldName; reason = "emergency-clearance dwell";
        end
    else
        state.clearSinceS = NaN;
        newName = oldName; reason = "emergency hysteresis";
    end
else
    state.clearSinceS = NaN;
end

transition = struct('occurred', newName ~= oldName, 'timestampS', world.timestampS, ...
    'from', oldName, 'to', newName, 'reason', reason);
if transition.occurred
    state.name = newName;
    state.lastTransitionTimeS = world.timestampS;
end
state.reason=reason;
end
