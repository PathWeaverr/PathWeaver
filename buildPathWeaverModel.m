function modelPath = buildPathWeaverModel()
%BUILDPATHWEAVERMODEL Generate runnable deterministic Simulink replay harness.
root=setupPath();
assert(~isempty(ver('simulink')),'PathWeaver:SimulinkUnavailable','Simulink is unavailable.');
pathweaver.simulation.prepareSimulinkReplay(2);
modelName='pathweaver_v0';
modelDirectory=fullfile(root,'simulink','models');
if ~exist(modelDirectory,'dir'),mkdir(modelDirectory);end
modelPath=fullfile(modelDirectory,[modelName '.slx']);
if bdIsLoaded(modelName),close_system(modelName,0);end
new_system(modelName); load_system(modelName);
set_param(modelName,'Solver','FixedStepDiscrete','FixedStep','0.05','StopTime','2', ...
    'PreLoadFcn','setupPath; pathweaver.simulation.prepareSimulinkReplay(2);');
add_block('simulink/Sources/From Workspace',[modelName '/Scenario - World State'], ...
    'VariableName','pathweaverReplay','Position',[35 80 175 120]);
names={'Prediction','Risk Map','Behaviour','Trajectory Planner','Controller','Vehicle Dynamics','Metrics and Logging'};
x=230;
previous='Scenario - World State';
for k=1:numel(names)
    block=[modelName '/' names{k}];
    add_block('simulink/Ports & Subsystems/Subsystem',block,'Position',[x 65 x+125 135]);
    add_line(modelName,[previous '/1'],[names{k} '/1'],'autorouting','on');
    previous=names{k}; x=x+165;
end
add_block('simulink/Sinks/To Workspace',[modelName '/Logged Output'], ...
    'VariableName','pathweaverSimulinkLog','SaveFormat','Structure With Time', ...
    'Position',[x 80 x+120 120]);
add_line(modelName,[previous '/1'],'Logged Output/1','autorouting','on');
annotation=sprintf(['Signal columns: ego x/y/speed | selected endpoint x/y | behaviour code | risk\n' ...
    'SIMULATED WORLD STATE - deterministic replay of the MATLAB closed loop']);
note=Simulink.Annotation(modelName,annotation);
note.Position=[35 175 650 220];
save_system(modelName,modelPath);
set_param(modelName,'SimulationCommand','update');
simulationOutput=sim(modelName);
assignin('base','pathweaverSimulinkLog',simulationOutput.pathweaverSimulinkLog);
save_system(modelName,modelPath);
close_system(modelName,0);
fprintf('Built and ran %s\n',modelPath);
end
