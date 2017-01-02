%Highway 1050 - 1350 
%Fall 1460 - 1560 
%Traffic 950 - 1050
close all

tic
%Paths to the input images and their groundtruth
sequencePath = '../datasets/highway/input/';
groundtruthPath = '../datasets/highway/groundtruth/';
%Initial and final frame of the sequence
iniFrame = 1050;
endFrame = 1350;

%Train the background model with the first half of the sequence
[means, deviations] = trainBackgroundModel(sequencePath, groundtruthPath, iniFrame, (endFrame-iniFrame)/2);


%Define the range of alpha
alpha= 1:5;

%Allocate memory for variables
numAlphas = size(alpha,2);

precision = zeros(1,numAlphas); recall = zeros(1,numAlphas); 
accuracy = zeros(1,numAlphas); FMeasure = zeros(1,numAlphas);

TPTotal=zeros(1,numAlphas);FPTotal=zeros(1,numAlphas);
TNTotal=zeros(1,numAlphas);FNTotal=zeros(1,numAlphas);

%Get the information of the input and groundtruth images
FilesInput = dir(strcat(sequencePath, '*jpg'));
FilesGroundtruth = dir(strcat(groundtruthPath, '*png'));

% k is used as an index to store information, in case alpha has 0, decimal or
%negative values
k=0;
for al = alpha
    k=k+1;
    %Detect foreground objects in the second half of the sequence
    for i = iniFrame+(endFrame-iniFrame)/2+1:endFrame
        %Read an image and convert it to grayscale
        image = imread(strcat(sequencePath,FilesInput(i).name));
        grayscale = double(rgb2gray(image));
        %Read the groundtruth image
        groundtruth = readGroundtruth(strcat(groundtruthPath,FilesGroundtruth(i).name));  
        %%%%% --> better results if we count the hard shadows as foreground
        %%%%% groundtruth = double(imread(strcat(groundtruthPath,FilesGroundtruth(i).name))) > 169;

        %Detect foreground objects
        detection = detectForeground(grayscale, means, deviations,al);
    
        %Compute the performance of the detector for the whole sequence
        [TP,FP,TN,FN] = computePerformance(groundtruth, detection);
        TPTotal(k)=TPTotal(k)+TP;
        FPTotal(k)=FPTotal(k)+FP;
        TNTotal(k)=TNTotal(k)+TN;
        FNTotal(k)=FNTotal(k)+FN;
        
        %Show the output of the detector
        figure(2)
        imshow(detection)
    end
    %Compute the performance of the detector for the whole sequence
    [precision(k),recall(k),accuracy(k),FMeasure(k)] = computeMetrics(TPTotal,FPTotal,TNTotal,FNTotal);
end

toc
%Plot some figures
figure()
plot(precision)
figure()
plot(recall)
figure()
plot(precision,recall)
figure()
plot(TPTotal)
hold on;
plot(FPTotal)
hold on;
plot(TNTotal)
hold on;
plot(FNTotal)
hold off;