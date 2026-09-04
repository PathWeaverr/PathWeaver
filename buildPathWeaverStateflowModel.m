function modelPath = buildPathWeaverStateflowModel()
%BUILDPATHWEAVERSTATEFLOWMODEL Generate and execute behaviour chart evidence.
root=setupPath();
assert(~isempty(ver('stateflow')),'PathWeaver:StateflowUnavailable','Stateflow is unavailable.');
modelName='pathweaver_behavior';
modelDirectory=fullfile(root,'simulink','models');
if ~exist(modelDirectory,'dir'),mkdir(modelDirectory);end
modelPath=fullfile(modelDirectory,[modelName '.slx']);
if bdIsLoaded(modelName),close_system(modelName,0);end
new_system(modelName); load_system(modelName);
set_param(modelName,'Solver','FixedStepDiscrete','FixedStep','0.05','StopTime','0.1');
add_block('sflib/Chart',[modelName '/PathWeaver Behaviour'], ...
    'Position',[340 80 560 300]);
rootObject=sfroot;
chart=find(rootObject,'-isa','Stateflow.Chart','Path',[modelName '/PathWeaver Behaviour']);
chart=chart(1); chart.Name='PathWeaver Behaviour';

inputNames={'riskScore','minimumTtcS','emergencyFlag','goalReached', ...
    'collisionFlag','lateralAvoid','leadDistanceM'};
defaults=[0,10,0,0,0,0,100];
for k=1:numel(inputNames)
    data=Stateflow.Data(chart); data.Name=inputNames{k}; data.Scope='Input'; data.Port=k;
    add_block('simulink/Sources/Constant',[modelName '/' inputNames{k}], ...
        'Value',num2str(defaults(k)),'Position',[40 25+42*k 155 48+42*k]);
    add_line(modelName,[inputNames{k} '/1'],['PathWeaver Behaviour/' num2str(k)],'autorouting','on');
end
output=Stateflow.Data(chart); output.Name='stateCode'; output.Scope='Output'; output.Port=1;
add_block('simulink/Sinks/To Workspace',[modelName '/Behaviour State'], ...
    'VariableName','pathweaverBehaviorState','SaveFormat','Array', ...
    'Position',[650 160 780 195]);
add_line(modelName,'PathWeaver Behaviour/1','Behaviour State/1','autorouting','on');

names={'CRUISE','FOLLOW','YIELD','AVOID','EMERGENCY_BRAKE','GOAL_REACHED','COLLISION'};
codes=0:6; positions=[20 30;200 30;380 30;20 180;200 180;380 180;560 180];
states=cell(1,numel(names));
for k=1:numel(names)
    state=Stateflow.State(chart); state.Name=names{k};
    state.Position=[positions(k,:) 125 65];
    state.LabelString=sprintf('%s\nentry: stateCode = %d;',names{k},codes(k));
    states{k}=state;
end
defaultTransition=Stateflow.Transition(chart); defaultTransition.Destination=states{1};
defaultTransition.DestinationOClock=0;

addTransition(chart,states{1},states{7},'[collisionFlag]');
addTransition(chart,states{1},states{6},'[goalReached && !collisionFlag]');
addTransition(chart,states{1},states{5},'[emergencyFlag || minimumTtcS < 0.75]');
addTransition(chart,states{1},states{3},['[!emergencyFlag && minimumTtcS >= 0.75 && ' ...
    '(minimumTtcS < 3.5 || riskScore > 0.9)]']);
addTransition(chart,states{1},states{4},['[minimumTtcS >= 3.5 && riskScore <= 0.9 && ' ...
    'lateralAvoid]']);
addTransition(chart,states{1},states{2},['[minimumTtcS >= 3.5 && riskScore <= 0.9 && ' ...
    '!lateralAvoid && leadDistanceM < 14]']);
for sourceIndex=2:5
    addTransition(chart,states{sourceIndex},states{7},'[collisionFlag]');
    addTransition(chart,states{sourceIndex},states{6},'[goalReached && !collisionFlag]');
    addTransition(chart,states{sourceIndex},states{5}, ...
        '[emergencyFlag || minimumTtcS < 0.75]');
    if sourceIndex~=3
        addTransition(chart,states{sourceIndex},states{3}, ...
            '[minimumTtcS >= 0.75 && (minimumTtcS < 3.5 || riskScore > 0.9)]');
    end
    addTransition(chart,states{sourceIndex},states{1}, ...
        ['[!emergencyFlag && minimumTtcS >= 3.5 && riskScore < 0.45 && ' ...
        '!lateralAvoid && leadDistanceM >= 14]']);
end
save_system(modelName,modelPath);
set_param(modelName,'SimulationCommand','update');
simulationOutput=sim(modelName);
assignin('base','pathweaverBehaviorState',simulationOutput.pathweaverBehaviorState);
save_system(modelName,modelPath); close_system(modelName,0);
fprintf('Built and ran %s\n',modelPath);
end

function addTransition(chart,source,destination,label)
transition=Stateflow.Transition(chart);
transition.Source=source; transition.Destination=destination;
transition.LabelString=label;
end
