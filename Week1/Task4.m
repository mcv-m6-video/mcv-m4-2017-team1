clearvars;
TestDirectory = '../results/highway/testB/';
GTDirectory = '../datasets/highway/reducedGT/';

FilesA = dir(strcat(TestDirectory, '*png'));
FilesGT = dir(strcat(GTDirectory, '*png'));

for k = 0:5:25
    precision = zeros(1,200); recall = zeros(1,200); FMeasure = zeros(1,200);
    for i = 1:length(FilesA)-k
        j=i+k;
        testImage = double(imread(strcat(TestDirectory, FilesA(i).name)));
        gtImage = double(imread(strcat(GTDirectory, FilesGT(j).name))) > 171; 
        
        [TP,FP,TN,FN] = computePerformance(gtImage, testImage);
        [precision(i),recall(i),accuracy,FMeasure(i)] = computeMetrics(TP,FP,TN,FN);

    end
    plot(FMeasure)
    drawnow()
    hold on;
    
end

