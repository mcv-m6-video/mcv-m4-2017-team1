clearvars;
TestDirectory = '../results/highway/testB/';
GTDirectory = '../datasets/highway/reducedGT/';
NFrames = 200;

FilesTest = dir(strcat(TestDirectory, '*png'));
FilesGT = dir(strcat(GTDirectory, '*png'));

FMeasureTotal = [];    
for k = 0:5:25
    precision = zeros(1,200); recall = zeros(1,200); FMeasure = zeros(1,200);

    TPTotal=0;FPTotal=0;TNTotal=0;FNTotal=0;
    for i = 1:length(FilesTest)-k
        j=i+k;
        testImage = double(imread(strcat(TestDirectory, FilesTest(i).name)));
        gtImage = double(imread(strcat(GTDirectory, FilesGT(j).name))) >= 170; 
        
        [TP,FP,TN,FN] = computePerformance(gtImage, testImage);
        TPTotal=TPTotal+TP;
        FPTotal=FPTotal+FP;
        TNTotal=TNTotal+TN;
        FNTotal=FNTotal+FN;
        [precision(i),recall(i),accuracy,FMeasure(i)] = computeMetrics(TP,FP,TN,FN);

    end
    [~,~,~,FMeasureT] = computeMetrics(TPTotal,FPTotal,TNTotal,FNTotal);
    FMeasureTotal = [FMeasureTotal FMeasureT];
    figure(1); plot(FMeasure)
    drawnow(); hold on;

end
    figure(2); plot(FMeasureTotal); 
