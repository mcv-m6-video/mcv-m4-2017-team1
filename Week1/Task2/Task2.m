clc;
clear all;

TestDirectoryA = '../results/highway/testA/';
TestDirectoryB = '../results/highway/testB/';
GTDirectory = '../datasets/highway/reducedGT/';

FilesTestA = dir(strcat(TestDirectoryA, '*png'));
FilesTestB = dir(strcat(TestDirectoryB, '*png'));
FilesGT1 = dir(strcat(GTDirectory, '*png'));

FilesGT=GetNamesGT(FilesGT1);

for i=1:length(FilesTestA)
A = imread(fullfile([TestDirectoryA '/'],FilesTestA(i).name)); % Read the A image
B = imread(fullfile([TestDirectoryB '/'],FilesTestB(i).name)); % Read the B image
GT = imread(fullfile([GTDirectory '/'],FilesGT{i})); % Read the GT image


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




