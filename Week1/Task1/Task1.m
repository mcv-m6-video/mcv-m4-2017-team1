clc;
clear all;
dirnameGT='../highway/groundtruth';
GroundTruth=dir(fullfile([dirnameGT '/'],'*.png')); % Get all .png files
dirnameAB='../results_testAB_changedetection/results/highway';
AB=dir(fullfile([dirnameAB '/'],'*.png')); % Get all .png files

[NamesA,NamesB]=GetNamesImg(AB);
NamesGT=GetNamesGT(GroundTruth);

TruePositiveA=0;
TruePositiveB=0;
TrueNegativeA=0;
TrueNegativeB=0;
FalsePositiveA=0;
FalsePositiveB=0;
FalseNegativeA=0;
FalseNegativeB=0;

for i=1:length(NamesA)
A = imread(fullfile([dirnameAB '/'],NamesA{i})); % Read the A image
B = imread(fullfile([dirnameAB '/'],NamesB{i})); % Read the B image
GT = imread(fullfile([dirnameGT '/'],NamesGT{i})); % Read the GT image

GT=BinarizeImg(GT);
[TPA,TNA,FPA,FNA] = CalculateMetrics(GT,A);
[TPB,TNB,FPB,FNB] = CalculateMetrics(GT,B);

TruePositiveA=TruePositiveA + TPA;
TruePositiveB=TruePositiveB + TPB;
TrueNegativeA=TrueNegativeA + TNA;
TrueNegativeB=TrueNegativeB + TNB;
FalsePositiveA=FalsePositiveA + FPA;
FalsePositiveB=FalsePositiveB + FPB;
FalseNegativeA=FalseNegativeA + FNA;
FalseNegativeB=FalseNegativeB + FNB;

end

[F1A,PrecisionA,RecallA] = GetF1PrecisionRecallTotal(TruePositiveA,TrueNegativeA,FalsePositiveA,FalseNegativeA);
[F1B,PrecisionB,RecallB] = GetF1PrecisionRecallTotal(TruePositiveB,TrueNegativeB,FalsePositiveB,FalseNegativeB);