clc;
close all;

%Directories of original images, Test and ground truth
InputDirectory = '../datasets/highway/reducedinput/';
TestDirectory = '../results/highway/testA/';
GTDirectory = '../datasets/highway/reducedGT/';

video = 0; %Decide to save a video with the evolution of F Measure or not

%Store the information from the directories (#images, names...)
FilesInput = dir(strcat(InputDirectory, '*jpg'));
FilesTest = dir(strcat(TestDirectory, '*png'));
FilesGT = dir(strcat(GTDirectory, '*png'));

%We assume both tests have the same number of images
NFrames = length(FilesTest);
%Initialize variables
FMeasure = zeros(1,NFrames);
TP = zeros(1,NFrames);
FG = zeros(1,NFrames);

%Create a videowriter
if video==1
    F(NFrames) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('FMeasure.avi');
    v.FrameRate = 10;
    open(v)
end

for i = 1:NFrames
    
    %Read input image
    realImage = imread(strcat(InputDirectory, FilesInput(i).name));
    %Read test image
    testImage = double(imread(strcat(TestDirectory, FilesTest(i).name)));
    %Read and binarize groundtruth image
    gtImage = double(imread(strcat(GTDirectory, FilesGT(i).name))) >= 170; 

    %Compute TP,FP,TN and FN and add them to the total
    [TP(i),FP,TN,FN] = computePerformance(gtImage, testImage);
    
    %Count non-zero values in the image (foreground values)
    FG(i) = nnz(testImage);
    
    %Compute FMeasure
    [~,~,~,FMeasure(i)] = computeMetrics(TP(i),FP,TN,FN);

    %Only show one of the plots as they are updated in real time
    if video==0
        %Plot results
        figure(1)
        ax1 = subplot(1,2,1);
        plot(1:i,TP(1:i),1:i,FG(1:i)); axis([0 200 0 12000]); 
        xlabel(ax1,'#frame'); ylabel(ax1,'Number of pixels'); 
        drawnow();

        ax2 = subplot(1,2,2);
        plot(1:i,FMeasure(1:i)); axis([0 200 0 1]); 
        xlabel(ax2,'#frame'); ylabel(ax2,'F Measure'); drawnow();
    elseif video==1
        %Plot the input image, test image and F Measure
        figure(3)  
        subplot(2,2,1); imshow(realImage); title('Input image')
        subplot(2,2,2); imshow(testImage); title('Result from Test')
        subplot(2,2,[3,4]); plot(1:i,FMeasure(1:i),'b'); title('F Measure');
        xlabel('# frame'); ylabel('F Measure')
        axis([0 200 0 1])
        drawnow(); 
        %Save the figure in a video
        F(i) = getframe(gcf);
        writeVideo(v,F(i));
    end

end

if video==1
    %Close video object
    close(v)
elseif video==0
    %Add legend of ax1
    legend(ax1,'True positives','Positives');
end

