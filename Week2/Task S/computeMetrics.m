function [precision,recall,accuracy,FMeasure] = computeMetrics(TP,FP,TN,FN)

precision = TP / (TP+FP);
recall = TP / (TP+FN);
accuracy = (TP+TN)/(TP+TN+FP+FN);
FMeasure = 2*precision*recall / (precision+recall);

%Change NaN's (which appear when dividing by 0) for 0s
precision(isnan(precision)) = 0;
recall(isnan(recall)) = 0;
FMeasure(isnan(FMeasure)) = 0;

end