function [TPTotal,FPTotal,TNTotal,FNTotal] = computeSequencePerformance(TestDirectory, GTDirectory)

%Store the information from the directories (#images, names...)
FilesTest = dir(strcat(TestDirectory, '*png'));
FilesGT = dir(strcat(GTDirectory, '*png'));

%Initialize variables
TPTotal=0;FPTotal=0;TNTotal=0;FNTotal=0;

%For each image in the directory, compute its performance and add it to the
%total
for i = 1:length(FilesTest)
    
    %Read test image
    testImage = double(imread(strcat(TestDirectory, FilesTest(i).name)));
    %Read and binarize groundtruth image
    gtImage = double(imread(strcat(GTDirectory, FilesGT(i).name))) >= 170; 

    %Compute TP,FP,TN and FN and add them to the total
    [TP,FP,TN,FN] = computePerformance(gtImage, testImage);
    TPTotal=TPTotal+TP;
    FPTotal=FPTotal+FP;
    TNTotal=TNTotal+TN;
    FNTotal=FNTotal+FN;

end


end