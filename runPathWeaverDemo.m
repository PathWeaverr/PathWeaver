function result = runPathWeaverDemo(options)
%RUNPATHWEAVERDEMO Run the deterministic PathWeaver vertical slice.
arguments
    options.seed (1,1) double = 26037
    options.plannerMode (1,1) string {mustBeMember(options.plannerMode,["risk-aware","baseline"])} = "risk-aware"
    options.visualization (1,1) logical = true
    options.video (1,1) logical = false
    options.outputDirectory (1,1) string = ""
    options.maximumSimulationTime (1,1) double = 32
end
root=setupPath(); cfg=defaultConfig(); cfg.seed=options.seed; cfg.mode=options.plannerMode;
cfg.maxSimulationTime=options.maximumSimulationTime;
cfg.visualization.enabled=options.visualization; cfg.visualization.video=options.video;
if strlength(options.outputDirectory)>0
    cfg.outputDirectory=char(options.outputDirectory);
else
    cfg.outputDirectory=fullfile(root,'artifacts');
end
if ~exist(cfg.outputDirectory,'dir'), mkdir(cfg.outputDirectory); end
if cfg.visualization.enabled
    view=pathweaver.visualization.TechnicalView(cfg);
    cleanup=onCleanup(@()view.close());
    callbacks.onStep=@(frame)view.update(frame);
else
    callbacks.onStep=[];
end
result=pathweaver.simulation.runSimulation(cfg,callbacks);
save(fullfile(cfg.outputDirectory,sprintf('pathweaver_%s_seed_%d.mat',cfg.mode,cfg.seed)),'result');
fprintf('\nPathWeaver %s seed %d\n',cfg.mode,cfg.seed);
fprintf('completed=%d collision=%d time=%.2f s path=%.2f m minTTC=%.2f s\n', ...
    result.completed,result.collision,result.log.timeS(end),result.metrics.pathLengthM,result.metrics.minimumTtcS);
fprintf('planner latency mean/max = %.2f / %.2f ms\n', ...
    result.metrics.averagePlannerLatencyS*1000,result.metrics.maximumPlannerLatencyS*1000);
if exist('cleanup','var'), clear cleanup; end
end
