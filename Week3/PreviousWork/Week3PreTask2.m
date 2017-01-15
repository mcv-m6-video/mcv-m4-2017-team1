%Highway 1050 - 1350 
%Fall 1460 - 1560 
%Traffic 950 - 1050
close all

video=0;
tic
%Paths to the input images and their groundtruth
sequencePath = {'datasets/highway/input/' 'datasets/traffic/input/' 'datasets/fall/input/'} ;
groundtruthPath = {'datasets/highway/groundtruth/' 'datasets/traffic/groundtruth/' 'datasets/fall/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950 1460];
endFrame = [1350 1050 1560];

for seq=2:numel(iniFrame)
    disp(['Sequence ' num2str(seq)])
%Train the background model with the first half of the sequence
[means, deviations] = trainBackgroundModelAllPix(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);
 na_means=means;
 na_deviations=deviations;
       

%Define the range of alpha
if seq==1
alpha= 3;
else
alpha=0:10;
end
%Define the range of rho
rho=linspace(0,1,10);
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
%conn=(4,8);
if video==1 
    NFrames=length(FilesInput);
    figure();
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
    F(NFrames) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('Fall-task2_rho08.avi');
    v.FrameRate = 10;
    open(v)
end
for al = alpha
    k=k+1;
    l=0;
    for r=rho
        l=l+1;
        disp(['Iteration with alpha ' num2str(al) ' index k ' num2str(k) '. Rho ' num2str(r) ' with index l ' num2str(l)]);
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
    %    detection=imfill(detection,conn,'holes');
       if video==1
            subplot(2,3,1); imshow(uint8(grayscale));
            title('Sequence')
            subplot(2,3,4); imshow(logical((detection)));
            title('Sequence segmentation')
            subplot(2,3,2); imshow(uint8(means));
            title ('Background mean')
            subplot(2,3,5); imagesc(uint8(old_means-means));
            colorbar;
            title('Mean difference between frames')
            subplot(2,3,3); imshow(uint8(deviations),[min(min(deviations)) max(max(deviations))]);
            title ('Background deviation')     
            subplot(2,3,6); imagesc(uint8(old_deviations-deviations));
            colorbar;
            title('Deviation difference between frames')
            drawnow();
             %Save the figure in a video
             if i==1321
             else
        F(i) = getframe(gcf);
        writeVideo(v,F(i));
             end
        end
        
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
if video==1
    %Close video object
    close(v)
end 
toc
%F-measure plots . Adaptive
figure;
surf(alpha,rho,vec_seq1(:,:,4))
hold on
ylabel('rho')
xlabel('alpha')
zlabel('Fmeasure')
title('Highway sequence')
figure;
surf(alpha,rho,vec_seq2(:,:,4))
hold on
ylabel('rho')
xlabel('alpha')
zlabel('Fmeasure')
title('Traffic sequence')
figure;
surf(alpha,rho,vec_seq3(:,:,4))
hold on
ylabel('rho')
xlabel('alpha')
zlabel('Fmeasure')
title('Fall sequence')

%BEST rho and alpha parameters for the 3 sequences
disp ('Best parameters for sequence 1')
ind=find(vec_seq1(:,:,4)==max(max(vec_seq1(:,:,4))));
[m,n]=ind2sub(size(vec_seq1(:,:,4)),ind);
disp(['Alpha: ' num2str(alpha(n)) ', Rho: ' num2str(rho(m)) ' with Fmeasure ' num2str(vec_seq1(m,n,4))])
wp_seq1=[m,n];
disp ('Best parameters for sequence 2')
ind=find(vec_seq2(:,:,4)==max(max(vec_seq2(:,:,4))));
[m,n]=ind2sub(size(vec_seq2(:,:,4)),ind);
disp(['Alpha: ' num2str(alpha(n)) ', Rho: ' num2str(rho(m)) ' with Fmeasure ' num2str(vec_seq2(m,n,4))])
wp_seq2=[m,n];
disp ('Best parameters for sequence 3')
ind=find(vec_seq3(:,:,4)==max(max(vec_seq3(:,:,4))));
[m,n]=ind2sub(size(vec_seq3(:,:,4)),ind);
disp(['Alpha: ' num2str(alpha(n)) ', Rho: ' num2str(rho(m)) ' with Fmeasure ' num2str(vec_seq3(m,n,4))])
wp_seq3=[m,n];
% F-measure plot comparison adaptive vs non-adaptive
figure();
plot(vec_seq1(1,:,4),'--g')
hold on
plot(vec_seq1(2,:,4),'g')
hold on
plot(vec_seq2(1,:,4),'--b')
hold on
plot(vec_seq2(2,:,4),'b')
hold on
plot(vec_seq3(1,:,4),'--r')
hold on
plot(vec_seq3(2,:,4),'r')
hold off
legend('Seq1 - non adaptive', 'Seq1 - adaptive, rho=0.11','Seq2 - non adaptive', 'Seq2 - adaptive, rho=0.11', 'Seq3 - non adaptive', 'Seq3 - adaptive, rho=0.11')
xlabel('alpha')
ylabel('FMeasure')

%Precision-Recall
figure()
 plot(vec_seq1(1,:,2),vec_seq1(1,:,1),'--g')
 hold on
 plot(vec_seq1(2,:,2),vec_seq1(3,:,1),'g')
 hold on
 plot(vec_seq2(1,:,2),vec_seq2(1,:,1),'--b')
 hold on
 plot(vec_seq2(2,:,2),vec_seq2(3,:,1),'b')
 hold on
 plot(vec_seq3(1,:,2),vec_seq3(1,:,1),'--r')
 hold on
 plot(vec_seq3(2,:,2),vec_seq3(4,:,1),'r')

 hold off

title('P-R curve for the 3 sequences (adaptive and non-adaptive)'); xlabel('Recall'); ylabel('Precision')
legend('Highway (non-adaptive)','Highway (adaptive,rho=0.11)','Traffic (non-adaptive)','Traffic (adaptive, rho=0.11)', 'Fall (non-adaptive)','Fall (adaptive,rho=0.11)'); axis([0 1 0 1])
