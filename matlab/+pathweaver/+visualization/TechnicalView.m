classdef TechnicalView < handle
    %TECHNICALVIEW Dark live renderer driven only by simulation state.
    properties (Access=private)
        Figure
        Axes
        Video
        Telemetry
        FrameStride = 2
        FrameCount = 0
    end
    methods
        function obj = TechnicalView(cfg)
            obj.Figure = figure('Name','PathWeaver v0.1', 'Color',[0.025 0.035 0.045], ...
                'Position',[80 80 1280 720]);
            obj.Axes = axes(obj.Figure, 'Position',[0.06 0.10 0.68 0.84], ...
                'Color',[0.025 0.035 0.045], 'XColor',[0.65 0.72 0.78], ...
                'YColor',[0.65 0.72 0.78]);
            obj.Telemetry = annotation(obj.Figure,'textbox',[0.77 0.28 0.21 0.48], ...
                'String','INITIALISING','Color',[0.82 0.88 0.92], ...
                'BackgroundColor',[0.05 0.08 0.10], ...
                'EdgeColor',[0.18 0.50 0.53],'FontName','Menlo', ...
                'FontSize',12,'FitBoxToText','off');
            if cfg.visualization.video
                if ~exist(cfg.outputDirectory,'dir'), mkdir(cfg.outputDirectory); end
                obj.Video = VideoWriter(fullfile(cfg.outputDirectory,'pathweaver_demo.mp4'),'MPEG-4');
                obj.Video.FrameRate = 20;
                open(obj.Video);
            end
        end
        function update(obj, frame)
            obj.FrameCount = obj.FrameCount + 1;
            if mod(obj.FrameCount-1,obj.FrameStride) ~= 0, return; end
            ax=obj.Axes; cla(ax); hold(ax,'on');
            scenario=frame.scenario; planner=frame.planner;
            fill(ax,[scenario.leftBoundaryWorldM(:,1);flipud(scenario.rightBoundaryWorldM(:,1))], ...
                [scenario.leftBoundaryWorldM(:,2);flipud(scenario.rightBoundaryWorldM(:,2))], ...
                [0.10 0.13 0.16],'EdgeColor','none');
            plot(ax,scenario.leftBoundaryWorldM(:,1),scenario.leftBoundaryWorldM(:,2), ...
                'Color',[0.55 0.63 0.70],'LineWidth',1.4);
            plot(ax,scenario.rightBoundaryWorldM(:,1),scenario.rightBoundaryWorldM(:,2), ...
                'Color',[0.55 0.63 0.70],'LineWidth',1.4);
            for k=1:numel(planner.candidateTrajectories)
                c=planner.candidateTrajectories(k);
                if c.isFeasible, color=[0.28 0.42 0.46]; else, color=[0.55 0.18 0.20]; end
                plot(ax,c.positionsWorldM(:,1),c.positionsWorldM(:,2),'Color',color,'LineWidth',0.6);
            end
            selected=planner.selectedTrajectory;
            plot(ax,selected.positionsWorldM(:,1),selected.positionsWorldM(:,2), ...
                'Color',[0.00 0.88 0.86],'LineWidth',2.5);
            for a=1:numel(frame.predictions)
                prediction=frame.predictions(a);
                plot(ax,prediction.expectedPositionsWorldM(:,1), ...
                    prediction.expectedPositionsWorldM(:,2),'--','Color',[0.95 0.67 0.20]);
                indices=unique(round(linspace(1,size(prediction.expectedPositionsWorldM,1),4)));
                for index=indices
                    drawEllipse(ax,prediction.expectedPositionsWorldM(index,:), ...
                        prediction.positionCovariancesWorldM2(:,:,index),[0.95 0.67 0.20]);
                end
            end
            for a=1:numel(scenario.agents)
                drawDisc(ax,scenario.agents(a).positionWorldM,scenario.agents(a).collisionRadiusM,[0.92 0.63 0.20]);
                text(ax,scenario.agents(a).positionWorldM(1),scenario.agents(a).positionWorldM(2)+0.7, ...
                    char(scenario.agents(a).class),'Color',[0.9 0.9 0.9],'FontSize',8);
            end
            obs=scenario.staticObstacles;
            drawDisc(ax,obs.positionWorldM,obs.geometry.radiusM,[0.65 0.25 0.18]);
            drawDisc(ax,frame.ego.positionWorldM,0.9,[0.00 0.88 0.86]);
            plot(ax,scenario.goalPositionWorldM(1),scenario.goalPositionWorldM(2),'p', ...
                'MarkerSize',14,'MarkerFaceColor',[0.25 0.85 0.50],'MarkerEdgeColor','none');
            xlim(ax,[max(0,frame.ego.positionWorldM(1)-14) min(scenario.roadXWorldM(end),frame.ego.positionWorldM(1)+42)]);
            ylim(ax,[-5 5]); axis(ax,'equal'); grid(ax,'on');
            ax.GridColor=[0.20 0.27 0.31]; ax.GridAlpha=0.35;
            title(ax,'PATHWEAVER  |  SIMULATED WORLD STATE','Color',[0.00 0.88 0.86]);
            xlabel(ax,'x world (m)'); ylabel(ax,'y world (m)');
            risk=planner.riskScore; if ~isfinite(risk), riskText='INF'; else, riskText=sprintf('%.3f',risk); end
            ttc=planner.minimumTtcS; if ~isfinite(ttc), ttcText='INF'; else, ttcText=sprintf('%.2f s',ttc); end
            telemetry=sprintf(['BEHAVIOUR  %s\nSPEED      %5.1f km/h\nTIME       %5.2f s\n' ...
                'LATENCY    %5.2f ms\nMIN TTC    %s\nRISK       %s\nCOST       %.2f\nSTATUS     %s'], ...
                frame.behavior.name,frame.ego.speedMps*3.6,scenario.timeS, ...
                planner.planningLatencyS*1000,ttcText,riskText,selected.totalCost,statusText(frame));
            obj.Telemetry.String=telemetry;
            drawnow limitrate;
            if ~isempty(obj.Video), writeVideo(obj.Video,getframe(obj.Figure)); end
        end
        function close(obj)
            if ~isempty(obj.Video), close(obj.Video); obj.Video=[]; end
        end
    end
end

function drawDisc(ax,centre,radius,color)
angle=linspace(0,2*pi,32);
fill(ax,centre(1)+radius*cos(angle),centre(2)+radius*sin(angle),color,'EdgeColor','none');
end
function drawEllipse(ax,centre,covariance,color)
[v,d]=eig((covariance+covariance')/2); angle=linspace(0,2*pi,40);
points=centre'+2*v*sqrt(max(d,0))*[cos(angle);sin(angle)];
plot(ax,points(1,:),points(2,:),'Color',color,'LineWidth',0.7);
end
function textValue=statusText(frame)
if frame.collision, textValue="COLLISION";
elseif frame.behavior.name=="GOAL_REACHED", textValue="COMPLETE";
else, textValue="RUNNING"; end
end
