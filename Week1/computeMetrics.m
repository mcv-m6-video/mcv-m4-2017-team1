function [precision,recall,accuracy,FMeasure] = computeMetrics(TP,FP,TN,FN)

precision = TP / (TP+FP);
precision(isnan(precision)) = 0;
recall = TP / (TP+FN);
recall(isnan(recall)) = 0;
accuracy = (TP+TN)/(TP+TN+FP+FN);
FMeasure = 2*precision*recall / (precision+recall);
FMeasure(isnan(FMeasure)) = 0;

end