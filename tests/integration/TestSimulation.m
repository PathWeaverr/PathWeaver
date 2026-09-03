function tests = TestSimulation
%TESTSIMULATION Closed-loop and conditional Simulink integration tests.
tests = functiontests(localfunctions);
end

function setupOnce(~)
setupPath();
end

function testShortClosedLoop(testCase)
cfg=defaultConfig(); cfg.maxSimulationTime=1;
r=pathweaver.simulation.runSimulation(cfg);
verifyGreaterThan(testCase,height(r.log),10);
verifyFalse(testCase,any(ismissing(r.log(:,1:7)),'all'));
verifyFalse(testCase,r.collision);
end

function testDefaultCompletes(testCase)
cfg=defaultConfig(); r=pathweaver.simulation.runSimulation(cfg);
verifyTrue(testCase,r.completed);
verifyFalse(testCase,r.collision);
end

function testSimulinkModelWhenAvailable(testCase)
assumeFalse(testCase,isempty(ver('simulink')));
modelPath=buildPathWeaverModel();
verifyTrue(testCase,isfile(modelPath));
load_system(modelPath); cleanup=onCleanup(@()close_system('pathweaver_v0',0));
set_param('pathweaver_v0','SimulationCommand','update');
clear cleanup
end
