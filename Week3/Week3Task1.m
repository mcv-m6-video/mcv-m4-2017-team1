%Highway 1050 - 1350 
%Fall 1460 - 1560 
%Traffic 950 - 1050
close all
clear all

video=1;
tic
%Paths to the input images and their groundtruth
sequencePath = {'../Archivos/highway/input/' '../Archivos/traffic/traffic/input/' '../Archivos/fall/fall/input/'} ;
groundtruthPath = {'../Archivos/highway/groundtruth/' '../Archivos/traffic/traffic/groundtruth/' '../Archivos/fall/fall/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950 1460];
endFrame = [1350 1050 1560];

for seq=1:3
    disp(['Sequence ' num2str(seq)])
%Train the background model with the first half of the sequence
[means, deviations] = trainBackgroundModelAllPix(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);
 na_means=means;
 na_deviations=deviations;
       

%Define the range of alpha
alpha=0:30;
%Define the range of rho
if seq==1
    rho=0.22;
    alpha=3;
elseif seq==2
    rho=0.22;
    alpha=4;
elseif seq==3
    rho=0.11;
    alpha=3;
end

alpha=0:30;
%Choose connectivity 4/8, discomment line or comment.
conn=4;
%conn=8;

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

% if video==1 
%     NFrames=length(FilesInput);
%     figure();
%     set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
%     F(NFrames) = struct('cdata',[],'colormap',[]);
%     v = VideoWriter('Fall-task2_rho08.avi');
%     v.FrameRate = 10;
%     open(v)
% end

    for al = alpha
        deviations=na_deviations;
        means=na_means;        
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
%         if video==1
%             subplot(2,3,1); imshow(uint8(grayscale));
%             title('Sequence')
%             subplot(2,3,4); imshow(logical((detection)));
%             title('Sequence segmentation')
%             subplot(2,3,2); imshow(uint8(means));
%             title ('Background mean')
%             subplot(2,3,5); imagesc(uint8(old_means-means));
%             colorbar;
%             title('Mean difference between frames')
%             subplot(2,3,3); imshow(uint8(deviations),[min(min(deviations)) max(max(deviations))]);
%             title ('Background deviation')     
%             subplot(2,3,6); imagesc(uint8(old_deviations-deviations));
%             colorbar;
%             title('Deviation difference between frames')
%             drawnow();
%              %Save the figure in a video
%              if i==1321
%              else
%                 F(i) = getframe(gcf);
%                 writeVideo(v,F(i));
%              end
%         end
        
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

    
    
%     if seq==1
%     vec_seq1(l,k,1)=precision(l,k);
%     vec_seq1(l,k,2)=recall(l,k);
%     vec_seq1(l,k,3)=accuracy(l,k);
%     vec_seq1(l,k,4)=FMeasure(l,k);
%     elseif seq==2
%     vec_seq2(l,k,1)=precision(l,k);
%     vec_seq2(l,k,2)=recall(l,k);
%     vec_seq2(l,k,3)=accuracy(l,k);
%     vec_seq2(l,k,4)=FMeasure(l,k);
%     else 
%     vec_seq3(l,k,1)=precision(l,k);
%     vec_seq3(l,k,2)=recall(l,k);
%     vec_seq3(l,k,3)=accuracy(l,k);
%     vec_seq3(l,k,4)=FMeasure(l,k);
%     end
  
    end
    end
end

% if video==1
%     %Close video object
%     close(v)
% end 
toc
%Precision
figure(); 
for seq=1:numel(iniFrame)
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
    plot(alpha, vec(seq,:,4))
    hold on;
end
hold off;
title('Fmeasure for the 3 sequences'); xlabel('Alpha'); ylabel('Fmeasure')
legend('Highway','Traffic','Fall'); ylim([0 1])


% %TP,FP,TN,FN
% figure()
% subplot(3,1,1)
% plot(alpha, vec(1,:,5), alpha, vec(1,:,6), alpha, vec(1,:,7), alpha, vec(1,:,8))
% title('TP,FP,TN & FN'); xlabel('Alpha'); ylabel('# pixels')
% legend('TP Highway','FP Highway','TN Highway','FN Highway')
% ylim([0 2*10^7])
% 
% subplot(3,1,2)
% plot(alpha, vec(2,:,5), alpha, vec(2,:,6), alpha, vec(2,:,7), alpha, vec(2,:,8))
% title('TP,FP,TN & FN'); xlabel('Alpha'); ylabel('# pixels')
% legend('TP Traffic','FP Traffic','TN Traffic','FN Traffic')
% ylim([0 2*10^7])
% 
% subplot(3,1,3)
% plot(alpha, vec(3,:,5), alpha, vec(3,:,6), alpha, vec(3,:,7), alpha, vec(3,:,8))
% title('TP,FP,TN & FN'); xlabel('Alpha'); ylabel('# pixels')
% legend('TP Fall','FP Fall','TN Fall','FN Fall')
% ylim([0 2*10^7])


for seq=1:3
    auc=trapz(vec(seq,:,1),vec(seq,:,2));
    disp(['AUC for sequence ' num2str(seq) ': ' num2str(auc)] )
end
