%Highway 1050 - 1350 
%Fall 1460 - 1560 
%Traffic 950 - 1050
close all

tic
%Paths to the input images and their groundtruth
sequencePath = {'datasets/highway/input/' 'datasets/traffic/input/'} ;
groundtruthPath = {'datasets/highway/groundtruth/' 'datasets/traffic/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950];
endFrame = [1350 1050];

for seq=1:numel(iniFrame)
%Train the background model with the first half of the sequence

[means, deviations] = trainBackgroundModel(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);


%Define the range of alpha
alpha= 0:10;

%Allocate memory for variables
numAlphas = size(alpha,2);

precision = zeros(1,numAlphas); recall = zeros(1,numAlphas); 
accuracy = zeros(1,numAlphas); FMeasure = zeros(1,numAlphas);

TPTotal=zeros(1,numAlphas);FPTotal=zeros(1,numAlphas);
TNTotal=zeros(1,numAlphas);FNTotal=zeros(1,numAlphas);

%Get the information of the input and groundtruth images
FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
FilesGroundtruth = dir(char(strcat(groundtruthPath(seq), '*png')));

% k is used as an index to store information, in case alpha has 0, decimal or
%negative values
k=0;
for al = alpha
    k=k+1;
    %Detect foreground objects in the second half of the sequence
    for i = iniFrame(seq)+(endFrame(seq)-iniFrame(seq))/2+1:endFrame(seq)
        %Read an image and convert it to grayscale
        image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
        grayscale = double(rgb2gray(image));
        %Read the groundtruth image
        groundtruth = readGroundtruth(char(strcat(groundtruthPath(seq),FilesGroundtruth(i).name)));  
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
        %figure(2)
        %imshow(detection)
    end
    %Compute the performance of the detector for the whole sequence
    [precision(k),recall(k),accuracy(k),FMeasure(k)] = computeMetrics(TPTotal,FPTotal,TNTotal,FNTotal);
    vec(seq,k,1)=precision(k);
    vec(seq,k,2)=recall(k);
    vec(seq,k,3)=accuracy(k);
    vec(seq,k,4)=FMeasure(k);
end
end

toc
%Plot some figures
figure()
plot(precision)
title('Precision')
xlabel('Alpha')
ylabel('Precision')
figure()
plot(recall)
title('Recall')
xlabel('Alpha')
ylabel('Recall')
figure()
for seq=1:numel(iniFrame)
plot(vec(seq,:,1),vec(seq,:,2))
hold on
end
hold off
title('P-R curve')
ylabel('Recall')
xlabel('Precision')
legend('Highway','Traffic')
figure()
plot(TPTotal)
hold on;
plot(FPTotal)
hold on;
plot(TNTotal)
hold on;
plot(FNTotal)
hold off;
legend('TP','FP','TN','FN')
xlabel('Alpha')
ylabel('Num. pixels')