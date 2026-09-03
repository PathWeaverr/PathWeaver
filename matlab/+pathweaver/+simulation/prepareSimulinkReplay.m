function replay = prepareSimulinkReplay(durationS)
%PREPARESIMULINKREPLAY Run core algorithms and provide numeric Simulink input.
if nargin<1, durationS=2; end
cfg=defaultConfig(); cfg.maxSimulationTime=durationS;
run=pathweaver.simulation.runSimulation(cfg);
codes=arrayfun(@behaviorCode,run.log.behavior);
risk=run.log.riskScore; risk(~isfinite(risk))=realmax('single');
values=[run.log.xWorldM run.log.yWorldM run.log.speedMps ...
    run.log.selectedEndXWorldM run.log.selectedEndYWorldM codes risk];
values(1,isnan(values(1,:)))=0;
replay=[run.log.timeS values];
assignin('base','pathweaverReplay',replay);
end

function code=behaviorCode(name)
names=["CRUISE","FOLLOW","YIELD","AVOID","EMERGENCY_BRAKE","GOAL_REACHED","COLLISION"];
code=find(names==name,1)-1;
end
