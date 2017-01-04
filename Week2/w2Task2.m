%Highway 1050 - 1350 
%Fall 1460 - 1560 
%Traffic 950 - 1050
close all

tic
%Paths to the input images and their groundtruth
sequencePath = {'datasets/highway/input/' 'datasets/traffic/input/' 'datasets/fall/input/'} ;
groundtruthPath = {'datasets/highway/groundtruth/' 'datasets/traffic/groundtruth/' 'datasets/fall/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950 1460];
endFrame = [1350 1050 1560];

for seq=1:numel(iniFrame)
%Train the background model with the first half of the sequence
[means, deviations] = trainBackgroundModel(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);


%Define the range of alpha
alpha= 0:30;
%Define the range of rho
rho=linspace(0,1,5);

%Allocate memory for variables
numAlphas = size(alpha,2);
numRhos= size(rho,2);
precision = zeros(numRhos,numAlphas); recall = zeros(numRhos,numAlphas); 
accuracy = zeros(numRhos,numAlphas); FMeasure = zeros(numRhos,numAlphas);

TPTotal=zeros(numRhos,numAlphas);FPTotal=zeros(numRhos,numAlphas);
TNTotal=zeros(numRhos,numAlphas);FNTotal=zeros(numRhos,numAlphas);

%Get the information of the input and groundtruth images
FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
FilesGroundtruth = dir(char(strcat(groundtruthPath(seq), '*png')));

% k is used as an index to store information, in case alpha has 0, decimal or
%negative values
k=0;
l=0;
for al = alpha
    k=k+1;
    l=0;
    for r=rho
        l=l+1;
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
        [detection,means,deviations] = detectForeground_adaptive(grayscale, means, deviations,al,r);
    
        %Compute the performance of the detector for the whole sequence
        [TP,FP,TN,FN] = computePerformance(groundtruth, detection);
        TPTotal(l,k)=TPTotal(l,k)+TP;
        FPTotal(l,k)=FPTotal(l,k)+FP;
        TNTotal(l,k)=TNTotal(l,k)+TN;
        FNTotal(l,k)=FNTotal(l,k)+FN;
        
        %Show the output of the detector
        %figure(2)
        %imshow(detection)
    end
    %Compute the performance of the detector for the whole sequence
    [precision(l,k),recall(l,k),accuracy(l,k),FMeasure(l,k)] = computeMetrics(TPTotal(l,k),FPTotal(l,k),TNTotal(l,k),FNTotal(l,k));
    if seq==1
    vec_seq1(l,k,1)=precision(l,k);
    vec_seq1(l,k,2)=recall(l,k);
    vec_seq1(l,k,3)=accuracy(l,k);
    vec_seq1(l,k,4)=FMeasure(l,k);
    elseif seq==2
    vec_seq2(l,k,1)=precision(l,k);
    vec_seq2(l,k,2)=recall(l,k);
    vec_seq2(l,k,3)=accuracy(l,k);
    vec_seq2(l,k,4)=FMeasure(l,k);
    else 
    vec_seq3(l,k,1)=precision(l,k);
    vec_seq3(l,k,2)=recall(l,k);
    vec_seq3(l,k,3)=accuracy(l,k);
    vec_seq3(l,k,4)=FMeasure(l,k);
    end
  
    end
end
end

toc

figure();
stem3(alpha,rho,vec_seq1(:,:,4))
hold on;
stem3(alpha,rho,vec_seq2(:,:,4))
hold on;
stem3(alpha,rho,vec_seq3(:,:,4))
hold off;
legend('Highway','Traffic','Fall')
ylabel('rho')
xlabel('alpha')
zlabel('Fmeasure')
title('Fmeasure for the 3 sequences')
