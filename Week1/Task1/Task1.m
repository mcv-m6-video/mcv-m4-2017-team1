clc;
clear all;

TestDirectoryA = '../results/highway/testA/';
TestDirectoryB = '../results/highway/testB/';
GTDirectory = '../datasets/highway/reducedGT/';

FilesTestA = dir(strcat(TestDirectoryA, '*png'));
FilesTestB = dir(strcat(TestDirectoryB, '*png'));
FilesGT1 = dir(strcat(GTDirectory, '*png'));

FilesGT=GetNamesGT(FilesGT1);

TruePositiveA=0;
TruePositiveB=0;
TrueNegativeA=0;
TrueNegativeB=0;
FalsePositiveA=0;
FalsePositiveB=0;
FalseNegativeA=0;
FalseNegativeB=0;

for i=1:length(FilesTestA)
A = imread(fullfile([TestDirectoryA '/'],FilesTestA(i).name)); % Read the A image
B = imread(fullfile([TestDirectoryB '/'],FilesTestB(i).name)); % Read the B image
GT = imread(fullfile([GTDirectory '/'],FilesGT{i})); % Read the GT image

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