function result = recordPathWeaverEvidence(options)
%RECORDPATHWEAVEREVIDENCE Generate slides, model proof, and real demo video.
arguments
    options.teamName (1,1) string = "Team PathWeaver"
    options.outputDirectory (1,1) string = ""
end
root=setupPath();
if strlength(options.outputDirectory)==0
    outputDirectory=fullfile(root,'artifacts','pitch');
else
    outputDirectory=char(options.outputDirectory);
end
generatePathWeaverPitchAssets(teamName=options.teamName,outputDirectory=outputDirectory);
modelPath=buildPathWeaverModel();
[~,modelName]=fileparts(modelPath); load_system(modelPath);
set_param(modelName,'ZoomFactor','FitSystem');
print(['-s' modelName],'-dpng',fullfile(outputDirectory,'simulink-model.png'));
close_system(modelName,0);
behaviorModelPath=buildPathWeaverStateflowModel();
[~,behaviorModelName]=fileparts(behaviorModelPath); load_system(behaviorModelPath);
chartPath=[behaviorModelName '/PathWeaver Behaviour']; open_system(chartPath);
print(['-s' chartPath],'-dpng','-r600',fullfile(outputDirectory,'stateflow-behaviour.png'));
close_system(behaviorModelName,0);
result=runPathWeaverDemo(visualization=true,video=true, ...
    outputDirectory=outputDirectory);
fprintf('Evidence package complete: %s\n',outputDirectory);
end
