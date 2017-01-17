%Highway 1050 - 1350 
%Fall 1460 - 1560 
%Traffic 950 - 1050
close all

video=1;
tic
%Paths to the input images and their groundtruth
sequencePath = {'../Archivos/highway/input/' '../Archivos/traffic/traffic/input/' '../Archivos/fall/fall/input/'} ;
groundtruthPath = {'../Archivos/highway/groundtruth/' '../Archivos/traffic/traffic/groundtruth/' '../Archivos/fall/fall/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950 1460];
endFrame = [1350 1050 1560];

for seq=1
    disp(['Sequence ' num2str(seq)])
%Train the background model with the first half of the sequence
[means, deviations] = trainBackgroundModelAllPix(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);
 na_means=means;
 na_deviations=deviations;
       

%Define the range of alpha
if seq==1
alpha= 0:30;
else
alpha=1:10;
end
%Define the range of rho
rho=0.22;

%Choose connectivity 4/8, discomment line or comment.
conn=4;
%conn=8;

%Allocate memory for variables
numAlphas = size(alpha,2);
numRhos= size(rho,2);
numConnec=size(connec,2);
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
            disp(['Iteration with alpha ' num2str(al) ' index k ' num2str(k) '. Rho ' num2str(r) ' with index l ' num2str(l) ' Connectivity of imfill= ' num2str(conn)]);
            means=na_means;
            deviations= na_deviations;
            %Detect foreground objects in the second half of the sequence
        for i = iniFrame(seq)+(endFrame(seq)-iniFrame(seq))/2+1:endFrame(seq)
            %Read an image and convert it to grayscale
            image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
            grayscale = double(rgb2gray(image));
            %Read the groundtruth image
            groundtruth = readGroundtruth(char(strcat(groundtruthPath(seq),FilesGroundtruth(i).name)));  
            %%%%% --> better results if we count the hard shadows as foreground
            %%%%% groundtruth = double(imread(strcat(groundtruthPath,FilesGroundtruth(i).name))) > 169;
            old_means=means;
            old_deviations=deviations;
      
            %Detect foreground objects
            [detection,means,deviations] = detectForeground_adaptive(grayscale, means, deviations,al,r);
            detection=imfill(detection,conn,'holes');
        
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
          
    vec(seq,k,1)=precision(l,k);
    vec(seq,k,2)=recall(l,k);
    vec(seq,k,3)=accuracy(l,k);
    vec(seq,k,4)=FMeasure(l,k);

  
    end
    end
end

toc
%Precision
figure(); 
for seq=1
    plot(alpha, vec(seq,:,1))
    hold on
end
hold off
title('Precision for the 3 sequences'); xlabel('Alpha'); ylabel('Precision')
legend('Highway','Traffic','Fall'); ylim([0 1])

%Recall
figure(); 
for seq=1:numel(iniFrame)
    plot(alpha, vec(seq,:,2))
    hold on
end
hold off
title('Recall for the 3 sequences'); xlabel('Alpha'); ylabel('Recall')
legend('Highway','Traffic','Fall'); ylim([0 1])

%Precision-Recall
figure()
for seq=1
    plot(vec(seq,:,2),vec(seq,:,1))
    hold on
end
hold off
title('P-R curve for the 3 sequences'); xlabel('Recall'); ylabel('Precision')
legend('Highway','Traffic','Fall'); axis([0 1 0 1])

%F Measure
figure();
for seq=1:numel(iniFrame)
    plot(alpha, vec(seq,:,4))
    hold on;
end
hold off;
title('Fmeasure for the 3 sequences'); xlabel('Alpha'); ylabel('Fmeasure')
legend('Highway','Traffic','Fall'); ylim([0 1])


for seq=1:3
    auc=trapz(vec(seq,:,1),vec(seq,:,2));
    disp(['AUC for sequence ' num2str(seq) ': ' num2str(auc)] )
end
