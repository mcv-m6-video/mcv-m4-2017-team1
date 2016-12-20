clearvars;
InputDirectory = '../datasets/highway/reducedinput/';
TestDirectory = '../results/highway/testB/';
GTDirectory = '../datasets/highway/reducedGT/';
NFrames = 200;

FilesInput = dir(strcat(InputDirectory, '*jpg'));
FilesTest = dir(strcat(TestDirectory, '*png'));
FilesGT = dir(strcat(GTDirectory, '*png'));
FMeasureTotal = [];
    
F(NFrames) = struct('cdata',[],'colormap',[]);
for k = 0 %0:5:25
    precision = zeros(1,200); recall = zeros(1,200); FMeasure = zeros(1,200);
    v = VideoWriter(strcat(int2str(k),'desynch.avi'));
    v.FrameRate = 10;
    open(v)
    TPTotal=0;FPTotal=0;TNTotal=0;FNTotal=0;
    for i = 1:length(FilesTest)-k
        j=i+k;
        realImage = imread(strcat(InputDirectory, FilesInput(i).name));
        testImage = double(imread(strcat(TestDirectory, FilesTest(i).name)));
        gtImage = double(imread(strcat(GTDirectory, FilesGT(j).name))) >= 170; 
        
        [TP,FP,TN,FN] = computePerformance(gtImage, testImage);
        TPTotal=TPTotal+TP;
        FPTotal=FPTotal+FP;
        TNTotal=TNTotal+TN;
        FNTotal=FNTotal+FN;
        [precision(i),recall(i),accuracy,FMeasure(i)] = computeMetrics(TP,FP,TN,FN);
        
        figure(3)  
        subplot(2,2,1); imshow(realImage); title('Input image')
        subplot(2,2,2); imshow(testImage); title('Result from Test A')
        subplot(2,2,[3,4]); plot(1:i,FMeasure(1:i),'b'); title('F Measure');
        xlabel('# frame'); ylabel('F Measure')

        axis([0 200 0 1])
        drawnow(); 
        F(i) = getframe(gcf);
        writeVideo(v,F(i));
    end
    [~,~,~,FMeasureT] = computeMetrics(TPTotal,FPTotal,TNTotal,FNTotal);
    FMeasureTotal = [FMeasureTotal FMeasureT];
    %figure(1); plot(FMeasure)
    %drawnow(); hold on;
    
    close(v)
end
    %figure(2); plot(FMeasureTotal); 

