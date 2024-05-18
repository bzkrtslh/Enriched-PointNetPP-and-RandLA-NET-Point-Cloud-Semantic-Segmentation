function metrics = CalculateMetrics(confusionMatrix)
    % Calculate TP, FP, FN from the confusion matrix
    TP = diag(confusionMatrix);
    FP = sum(confusionMatrix, 1)' - TP;
    FN = sum(confusionMatrix, 2) - TP;

    % Calculate metrics
    accuracy   = sum(TP) / sum(confusionMatrix(:));
    recall     = (TP ./ (TP + FN));
    precision  = (TP ./ (TP + FP));
    f1score    = (2 * (precision .* recall) ./ (precision + recall));
    meanIoU    = mean(TP ./ (TP + FP + FN));
    kappa      = (sum(TP) * sum(confusionMatrix(:)) - sum(confusionMatrix, 1) * sum(confusionMatrix, 2)) / (sum(confusionMatrix(:))^2 - sum(confusionMatrix, 1) * sum(confusionMatrix, 2));
    
    % Calculate class proportions
    classProportions = sum(confusionMatrix, 2) / sum(confusionMatrix(:));
    
    % Calculate weighted IoU (mIoU)
    weightedIoU = classProportions' * (TP ./ (TP + FP + FN));

    % Create a structure to store the metrics
    precision(isnan(precision))=0;
    f1score(isnan(f1score))    =0;

    metrics.Accuracy    = accuracy;
    metrics.Recall      = mean(recall);
    metrics.MeanIoU     = meanIoU;
    metrics.F1Score     = mean(f1score);
    metrics.Kappa       = kappa;
    metrics.Precision   = mean(precision);
    metrics.WeightedIoU = weightedIoU;
end
