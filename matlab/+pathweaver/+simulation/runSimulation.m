function result = runSimulation(cfg, callbacks)
%RUNSIMULATION Execute deterministic closed-loop simulation.
arguments
    cfg (1,1) struct
    callbacks.onStep = []
end
scenario = pathweaver.scenario.createVillageCrossing(cfg);
ego = cfg.scenario.egoInitial;
behavior = pathweaver.behavior.initialState();
controller = pathweaver.control.initialControllerState();
maxSteps = ceil(cfg.maxSimulationTime/cfg.dt);
replanSteps = max(1, round(cfg.replanInterval/cfg.dt));

timeS = nan(maxSteps+1,1); positions = nan(maxSteps+1,2);
speedMps = nan(maxSteps+1,1); accelerationMps2 = nan(maxSteps+1,1);
steeringRad = nan(maxSteps+1,1); riskScore = nan(maxSteps+1,1);
ttcS = nan(maxSteps+1,1); latencyS = nan(maxSteps+1,1);
curvaturePerM = nan(maxSteps+1,1); behaviorName = strings(maxSteps+1,1);
timeS(1)=0; positions(1,:)=ego.positionWorldM; speedMps(1)=ego.speedMps;
accelerationMps2(1)=0; steeringRad(1)=0; behaviorName(1)=behavior.name;
transitions = struct('occurred',{},'timestampS',{},'from',{},'to',{},'reason',{});
planner = [];
collision = false; collisionReason = ""; step = 0;

while step < maxSteps
    step = step + 1;
    scenario = pathweaver.scenario.advanceAgents(scenario, ego, cfg.dt, cfg);
    world = pathweaver.scenario.worldState(scenario, ego);
    if isempty(planner) || mod(step-1, replanSteps) == 0
        predictions = pathweaver.prediction.predictAgents( ...
            world.agents, world.timestampS, cfg);
        planner = pathweaver.planning.planTrajectories(world, predictions, scenario, cfg);
    end
    [collisionNow, ~] = pathweaver.simulation.detectCollision(ego, scenario, cfg);
    [behavior, transition] = pathweaver.behavior.updateState( ...
        behavior, planner, world, scenario, collisionNow, cfg);
    planner.behaviorState = behavior.name;
    if transition.occurred
        transitions(end+1) = transition; %#ok<AGROW>
    end
    emergency = planner.emergencyFlag || behavior.name == "EMERGENCY_BRAKE";
    [command, controller] = pathweaver.control.trackTrajectory( ...
        ego, planner.selectedTrajectory, emergency, controller, cfg);
    ego = pathweaver.control.updateBicycle(ego, command, cfg.dt, cfg);
    [collision, collisionReason] = pathweaver.simulation.detectCollision(ego, scenario, cfg);

    row = step + 1;
    timeS(row)=ego.timestampS; positions(row,:)=ego.positionWorldM;
    speedMps(row)=ego.speedMps; accelerationMps2(row)=ego.accelerationMps2;
    steeringRad(row)=ego.steeringRad; riskScore(row)=planner.riskScore;
    ttcS(row)=planner.minimumTtcS; latencyS(row)=planner.planningLatencyS;
    curvaturePerM(row)=tan(ego.steeringRad)/cfg.ego.wheelbaseM;
    behaviorName(row)=behavior.name;

    frame = struct('scenario',scenario,'world',world,'ego',ego, ...
        'predictions',predictions,'planner',planner,'behavior',behavior, ...
        'collision',collision,'collisionReason',collisionReason);
    if ~isempty(callbacks.onStep), callbacks.onStep(frame); end
    if collision || norm(ego.positionWorldM-scenario.goalPositionWorldM) <= cfg.goalToleranceM
        break
    end
end

rows = 1:step+1;
log = table(timeS(rows), positions(rows,1), positions(rows,2), speedMps(rows), ...
    accelerationMps2(rows), steeringRad(rows), curvaturePerM(rows), ...
    riskScore(rows), ttcS(rows), latencyS(rows), behaviorName(rows), ...
    'VariableNames', {'timeS','xWorldM','yWorldM','speedMps','accelerationMps2', ...
    'steeringRad','curvaturePerM','riskScore','minimumTtcS','planningLatencyS','behavior'});
completed = ~collision && norm(ego.positionWorldM-scenario.goalPositionWorldM) <= cfg.goalToleranceM;
metrics = pathweaver.evaluation.computeMetrics(log, completed, collision);
result = struct('config',cfg,'scenario',scenario,'finalEgo',ego,'log',log, ...
    'transitions',transitions,'metrics',metrics,'completed',completed, ...
    'collision',collision,'collisionReason',collisionReason,'lastFrame',frame);
end
