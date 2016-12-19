clc;
clear all;
dirnameGT='../highway/groundtruth';
GroundTruth=dir(fullfile([dirnameGT '/'],'*.png')); % Get all .png files
dirnameAB='../results_testAB_changedetection/results/highway';
AB=dir(fullfile([dirnameAB '/'],'*.png')); % Get all .png files

[NamesA,NamesB]=GetNamesImg(AB);
NamesGT=GetNamesGT(GroundTruth);

for i=1:length(NamesA)
A = imread(fullfile([dirnameAB '/'],NamesA{i})); % Read the A image
B = imread(fullfile([dirnameAB '/'],NamesB{i})); % Read the B image
GT = imread(fullfile([dirnameGT '/'],NamesGT{i})); % Read the GT image

GT=BinarizeImg(GT);
[TPA,TNA,FPA,FNA] = CalculateMetrics(GT,A);
[TPB,TNB,FPB,FNB] = CalculateMetrics(GT,B);

FGA=ForeGroundCount(A);
FGB=ForeGroundCount(B);

F1A=CalculateF1(TPA,FPA,FNA);
F1B=CalculateF1(TPB,FPB,FNB);

TruePositiveA{i}= TPA;
TruePositiveB{i}= TPB;
ForeGroundA{i}=FGA;
ForeGroundB{i}=FGB;

F1framesA{i}=F1A;
F1framesB{i}=F1B;
end




