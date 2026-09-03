function [integratedRisk, hardCollision, minimumSeparationM] = dynamicRisk(positionsWorldM, predictions, cfg)
%DYNAMICRISK Score time-aligned Gaussian occupancy; not collision probability.
n = size(positionsWorldM, 1);
riskByTime = zeros(n, 1);
hardCollision = false;
minimumSeparationM = inf;
egoRadius = hypot(cfg.ego.lengthM/2, cfg.ego.widthM/2)*0.72;
for a = 1:numel(predictions)
    prediction = predictions(a);
    count = min(n, size(prediction.expectedPositionsWorldM, 1));
    for k = 1:count
        delta = positionsWorldM(k,:) - prediction.expectedPositionsWorldM(k,:);
        separation = norm(delta) - egoRadius - prediction.collisionRadiusM;
        minimumSeparationM = min(minimumSeparationM, separation);
        if separation <= cfg.planner.dynamicMarginM
            hardCollision = true;
        end
        covariance = prediction.positionCovariancesWorldM2(:,:,k) + ...
            diag([(egoRadius + prediction.collisionRadiusM)^2, ...
            (cfg.ego.widthM/2 + prediction.collisionRadiusM)^2]);
        factor = chol(covariance, 'lower');
        whitened = factor\delta';
        mahalanobis2 = sum(whitened.^2);
        uncertainty = 1 + cfg.prediction.uncertaintyBeta*sqrt(trace( ...
            prediction.positionCovariancesWorldM2(:,:,k)));
        riskByTime(k) = riskByTime(k) + exp(-0.5*mahalanobis2)*uncertainty;
        if mahalanobis2 <= cfg.prediction.hardMahalanobis2
            hardCollision = true;
        end
    end
end
integratedRisk = trapz((0:n-1)'*cfg.planDt, riskByTime);
end
