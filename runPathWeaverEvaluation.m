function results = runPathWeaverEvaluation(options)
%RUNPATHWEAVEREVALUATION Compare modes over identical deterministic seeds.
arguments
    options.seeds (1,:) double = 26037:26046
    options.outputDirectory (1,1) string = ""
end
root=setupPath();
if strlength(options.outputDirectory)==0
    outputDirectory=fullfile(root,'artifacts','evaluation');
else
    outputDirectory=char(options.outputDirectory);
end
if ~exist(outputDirectory,'dir'), mkdir(outputDirectory); end
modes=["baseline","risk-aware"];
rows=cell(numel(options.seeds)*numel(modes),1); row=0;
for mode=modes
    for seed=options.seeds
        cfg=defaultConfig(); cfg.mode=mode; cfg.seed=seed;
        cfg.visualization.enabled=false; cfg.visualization.video=false;
        run=pathweaver.simulation.runSimulation(cfg);
        row=row+1; m=run.metrics;
        rows{row}=table(seed,mode,m.collision,m.completed,m.minimumTtcS, ...
            m.timeToGoalS,m.pathLengthM,m.averagePlannerLatencyS, ...
            m.maximumPlannerLatencyS,m.integratedAbsoluteJerkMps2, ...
            m.maximumCurvaturePerM,m.emergencyBrakingCount, ...
            'VariableNames',{'seed','mode','collision','completed','minimumTtcS', ...
            'timeToGoalS','pathLengthM','averagePlannerLatencyS', ...
            'maximumPlannerLatencyS','integratedAbsoluteJerkMps2', ...
            'maximumCurvaturePerM','emergencyBrakingCount'});
        fprintf('%s seed %d: complete=%d collision=%d\n',mode,seed,m.completed,m.collision);
    end
end
results=vertcat(rows{:});
save(fullfile(outputDirectory,'evaluation_results.mat'),'results');
writetable(results,fullfile(outputDirectory,'evaluation_results.csv'));

summaryFigure=figure('Visible','off','Color','w','Position',[100 100 900 420]);
tiledlayout(summaryFigure,1,2);
nexttile; bar([mean(results.completed(results.mode=="baseline")), ...
    mean(results.completed(results.mode=="risk-aware")); ...
    mean(results.collision(results.mode=="baseline")), ...
    mean(results.collision(results.mode=="risk-aware"))]);
set(gca,'XTickLabel',{'Completion','Collision'}); legend('Baseline','Risk-aware');
ylabel('Rate'); ylim([0 1]); title('Measured outcomes'); grid on;
nexttile; boxchart(categorical(results.mode),results.averagePlannerLatencyS*1000);
ylabel('Mean planner latency (ms)'); title('Measured runtime'); grid on;
exportgraphics(summaryFigure,fullfile(outputDirectory,'evaluation_summary.png'));
close(summaryFigure);
disp(groupsummary(results,'mode','mean',{'collision','completed','minimumTtcS', ...
    'timeToGoalS','pathLengthM','averagePlannerLatencyS'}));
end
