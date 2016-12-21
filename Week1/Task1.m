clc;
clear all;
close all;

TestDirectoryA = '../results/highway/testA/';
TestDirectoryB = '../results/highway/testB/';
GTDirectory = '../datasets/highway/reducedGT/';

% TEST A RESULTS
[TPTotal,FPTotal,TNTotal,FNTotal] = computeSequencePerformance(TestDirectoryA, GTDirectory);
%Compute metrics from the total TP,FP,TN and FN of the sequence
[precision,recall,accuracy,FMeasure] = computeMetrics(TPTotal,FPTotal,TNTotal,FNTotal);

fprintf('TEST A:\n')
fprintf('Precision: %f\n', precision)
fprintf('Recall: %f\n', recall)
fprintf('Accuracy: %f\n', accuracy)
fprintf('F measure: %f\n\n', FMeasure)

% TEST B RESULTS
[TPTotal,FPTotal,TNTotal,FNTotal] = computeSequencePerformance(TestDirectoryB, GTDirectory);
%Compute metrics from the total TP,FP,TN and FN of the sequence
[precision,recall,accuracy,FMeasure] = computeMetrics(TPTotal,FPTotal,TNTotal,FNTotal);fprintf('TEST B:\n')

fprintf('Precision: %f\n', precision)
fprintf('Recall: %f\n', recall)
fprintf('Accuracy: %f\n', accuracy)
fprintf('F measure: %f\n\n', FMeasure)