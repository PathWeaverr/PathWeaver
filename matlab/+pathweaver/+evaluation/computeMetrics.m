function metrics = computeMetrics(log, completed, collision)
%COMPUTEMETRICS Calculate only metrics derived from simulation telemetry.
deltaPosition = hypot(diff(log.xWorldM), diff(log.yWorldM));
jerk = gradient(log.accelerationMps2, max(mean(diff(log.timeS)), eps));
finiteTtc = log.minimumTtcS(isfinite(log.minimumTtcS));
finiteLatency = log.planningLatencyS(isfinite(log.planningLatencyS));
metrics = struct('collision', logical(collision), 'completed', logical(completed), ...
    'minimumTtcS', minOrInf(finiteTtc), 'timeToGoalS', NaN, ...
    'pathLengthM', sum(deltaPosition), 'averagePlannerLatencyS', meanOrNaN(finiteLatency), ...
    'maximumPlannerLatencyS', maxOrNaN(finiteLatency), ...
    'integratedAbsoluteJerkMps2', trapz(log.timeS, abs(jerk)), ...
    'maximumCurvaturePerM', max(abs(log.curvaturePerM)), ...
    'emergencyBrakingCount', sum(diff(log.behavior=="EMERGENCY_BRAKE")==1));
if completed, metrics.timeToGoalS = log.timeS(end); end
end

function value = minOrInf(x)
if isempty(x), value = inf; else, value = min(x); end
end
function value = meanOrNaN(x)
if isempty(x), value = NaN; else, value = mean(x); end
end
function value = maxOrNaN(x)
if isempty(x), value = NaN; else, value = max(x); end
end
