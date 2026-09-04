function code = runStateflowCase(modelPath, conditions)
%RUNSTATEFLOWCASE Execute one reset Stateflow decision case.
[~,modelName]=fileparts(modelPath);
load_system(modelPath); cleanup=onCleanup(@()close_system(modelName,0));
names=fieldnames(conditions);
for k=1:numel(names)
    set_param([modelName '/' names{k}],'Value',num2str(conditions.(names{k})));
end
output=sim(modelName);
values=output.pathweaverBehaviorState;
code=values(end);
clear cleanup
end
