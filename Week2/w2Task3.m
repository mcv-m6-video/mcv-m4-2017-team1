%Highway 1050 - 1350
%Fall 1460 - 1560
%Traffic 950 - 1050
clear all
clc

tic
%Paths to the input images and their groundtruth
sequencePath = {'../Archivos/highway/input/' '../Archivos/traffic/traffic/input/' '../Archivos/fall/fall/input/'} ;
groundtruthPath = {'../Archivos/highway/groundtruth/' '../Archivos/traffic/traffic/groundtruth/' '../Archivos/fall/fall/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950 1460];
endFrame = [1350 1050 1560];

for seq=1:numel(iniFrame)
    
    Gauss=1:6;
    numGauss=size(Gauss,2);
    
    precision = zeros(1,numGauss); recall = zeros(1,numGauss);
    accuracy = zeros(1,numGauss); FMeasure = zeros(1,numGauss);
    
    TPTotal=zeros(1,numGauss);FPTotal=zeros(1,numGauss);
    TNTotal=zeros(1,numGauss);FNTotal=zeros(1,numGauss);
    
    FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
    FilesGroundtruth = dir(char(strcat(groundtruthPath(seq), '*png')));
    
    for k=Gauss
        numGaus=k;
        detector = vision.ForegroundDetector('NumTrainingFrames',((endFrame(seq)-iniFrame(seq))/2), 'NumGaussians',numGaus, 'InitialVariance',30^2) ;
        for i = iniFrame(seq):(iniFrame(seq)+(endFrame(seq)-iniFrame(seq))/2)
            image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
            %grayscale = double(rgb2gray(image));
            grayscale=image;% read the next video frame
            foreground = step(detector, grayscale);
        end
        
        for i=iniFrame(seq)+(endFrame(seq)-iniFrame(seq))/2+1:endFrame(seq)
            image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
            %grayscale = double(rgb2gray(image));
            grayscale=image;
            groundtruth = readGroundtruth(char(strcat(groundtruthPath(seq),FilesGroundtruth(i).name)));
            foreground = step(detector, grayscale);
            if seq==2
                se = strel('disk',3);
            else
                se = strel('disk',1);
            end
            foreground=imopen(foreground,se);
            
            [TP,FP,TN,FN] = computePerformance(groundtruth, foreground);
            TPTotal(k)=TPTotal(k)+TP;
            FPTotal(k)=FPTotal(k)+FP;
            TNTotal(k)=TNTotal(k)+TN;
            FNTotal(k)=FNTotal(k)+FN;
        end
        [precision(k),recall(k),accuracy(k),FMeasure(k)] = computeMetrics(TPTotal(k),FPTotal(k),TNTotal(k),FNTotal(k));
        vec(seq,k,1)=precision(k);
        vec(seq,k,2)=recall(k);
        vec(seq,k,3)=accuracy(k);
        vec(seq,k,4)=FMeasure(k);
        vec(seq,k,5)=TPTotal(k);
        vec(seq,k,6)=FPTotal(k);
        vec(seq,k,7)=TNTotal(k);
        vec(seq,k,8)=FNTotal(k);
        
    end
    
end


toc
%Plot some figures

%Precision
figure();
for seq=1:numel(iniFrame)
    plot(Gauss, vec(seq,:,1))
    hold on
end
hold off
title('Precision for the 3 sequences'); xlabel('Gauss'); ylabel('Precision')
legend('Highway','Traffic','Fall'); ylim([0 1])

%Recall
figure();
for seq=1:numel(iniFrame)
    plot(Gauss, vec(seq,:,2))
    hold on
end
hold off
title('Recall for the 3 sequences'); xlabel('Gauss'); ylabel('Recall')
legend('Highway','Traffic','Fall'); ylim([0 1])

%Precision-Recall
figure()
for seq=1:numel(iniFrame)
    plot(vec(seq,:,2),vec(seq,:,1))
    hold on
end
hold off
title('P-R curve for the 3 sequences'); xlabel('Recall'); ylabel('Precision')
legend('Highway','Traffic','Fall'); axis([0 1 0 1])

%F Measure
figure();
for seq=1:numel(iniFrame)
    plot(Gauss, vec(seq,:,4))
    hold on;
end
hold off;
title('Fmeasure for the 3 sequences'); xlabel('Gauss'); ylabel('Fmeasure')
legend('Highway','Traffic','Fall'); ylim([0 1])


%TP,FP,TN,FN
figure()
subplot(3,1,1)
plot(Gauss, vec(1,:,5), Gauss, vec(1,:,6), Gauss, vec(1,:,7), Gauss, vec(1,:,8))
title('TP,FP,TN & FN'); xlabel('Gauss'); ylabel('# pixels')
legend('TP Highway','FP Highway','TN Highway','FN Highway')
ylim([0 2*10^7])

subplot(3,1,2)
plot(Gauss, vec(2,:,5), Gauss, vec(2,:,6), Gauss, vec(2,:,7), Gauss, vec(2,:,8))
title('TP,FP,TN & FN'); xlabel('Gauss'); ylabel('# pixels')
legend('TP Traffic','FP Traffic','TN Traffic','FN Traffic')
ylim([0 2*10^7])

subplot(3,1,3)
plot(Gauss, vec(3,:,5), Gauss, vec(3,:,6), Gauss, vec(3,:,7), Gauss, vec(3,:,8))
title('TP,FP,TN & FN'); xlabel('Gauss'); ylabel('# pixels')
legend('TP Fall','FP Fall','TN Fall','FN Fall')
ylim([0 2*10^7])


for seq=1:numel(iniFrame)
    auc=trapz(vec(seq,:,1),vec(seq,:,2));
    disp(['AUC for sequence ' num2str(seq) ': ' num2str(auc)] )
end
