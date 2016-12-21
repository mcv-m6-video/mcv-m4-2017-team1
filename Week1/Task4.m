clearvars;

%Directories of Test and ground truth
TestDirectory = '../results/highway/testA/';
GTDirectory = '../datasets/highway/reducedGT/';

%Store the information from the directories (#images, names...)
FilesTest = dir(strcat(TestDirectory, '*png'));
FilesGT = dir(strcat(GTDirectory, '*png'));

%We assume both tests have the same number of images
NFrames = length(FilesTest);

FMeasureTotal = [];    
% k indicates the number of desyncrhonized frames
for k = 0:5:25
    %Restore metrics for each k
    precision = zeros(1,NFrames); recall = zeros(1,NFrames); FMeasure = zeros(1,NFrames);
    TPTotal=0;FPTotal=0;TNTotal=0;FNTotal=0;
    
    for i = 1:length(FilesTest)-k
        j=i+k; %j is the index for the ground truth image (desynchronized)
        testImage = double(imread(strcat(TestDirectory, FilesTest(i).name)));
        gtImage = double(imread(strcat(GTDirectory, FilesGT(j).name))) >= 170; 
        
        %Compute the performance of the frame and add them to the total
        [TP,FP,TN,FN] = computePerformance(gtImage, testImage);
        TPTotal=TPTotal+TP;
        FPTotal=FPTotal+FP;
        TNTotal=TNTotal+TN;
        FNTotal=FNTotal+FN;
        %Compute the metrics of the frame to plot the FMeasure
        [precision(i),recall(i),accuracy,FMeasure(i)] = computeMetrics(TP,FP,TN,FN);

    end
    %Compute the metrics of the whole sequence and save the results for each value of k
    [precisionT,recallT,~,FMeasureT] = computeMetrics(TPTotal,FPTotal,TNTotal,FNTotal);
    FMeasureTotal = [FMeasureTotal FMeasureT];
    %Plot the FMeasure of each k
    figure(1); plot(FMeasure)
    drawnow(); hold on;

end
%Plot the evolution of the total FMeasure with respect to the #
%desynchronized frames
figure(2); plot(0:5:25,FMeasureTotal); 

