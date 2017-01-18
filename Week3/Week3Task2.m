%Highway 1050 - 1350
%Fall 1460 - 1560
%Traffic 950 - 1050
close all
clear all

video=1;
tic
%Paths to the input images and their groundtruth
sequencePath = {'datasets/highway/input/' 'datasets/traffic/input/' 'datasets/fall/input/'} ;
groundtruthPath = {'datasets/highway/groundtruth/' 'datasets/traffic/groundtruth/' 'datasets/fall/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950 1460];
endFrame = [1350 1050 1560];

for seq=1:numel(iniFrame)
    disp(['Sequence ' num2str(seq)])
    %Train the background model with the first half of the sequence
    [means, deviations] = trainBackgroundModelAllPix(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);
    na_means=means;
    na_deviations=deviations;
    
    
    alpha=0:30;
    %Best rho and alpha values from Week2
    if seq==1
        rho=0.22;
        %   alpha=3;
    elseif seq==2
        rho=0.22;
        %   alpha=4;
    elseif seq==3
        rho=0.11;
        %   alpha=3;
    end
    
    %Define Range of Pixels P for connectivity
    P=0:100:1000;
    %Choose connectivity 4/8, discomment line or comment.
    conn=4;
    %conn=8;
    
    %Allocate memory for variables
    numAlphas = size(alpha,2);
    numRhos= size(rho,2);
    numP=size(P,2);
    
    figure();
    %Get the information of the input and groundtruth images
    FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
    FilesGroundtruth = dir(char(strcat(groundtruthPath(seq), '*png')));
    
    % k is used as an index to store information
  
    p=0;
    
    for Pixels = P
        p=p+1;
        k=0;
        
        precision = zeros(1,numAlphas); recall = zeros(1,numAlphas);
        accuracy = zeros(1,numAlphas); FMeasure = zeros(1,numAlphas);
        
        TPTotal=zeros(1,numAlphas);FPTotal=zeros(1,numAlphas);
        TNTotal=zeros(1,numAlphas);FNTotal=zeros(1,numAlphas);
        
        for al = alpha
            k=k+1;
            disp(['Iteration with alpha ' num2str(al) ' index k ' num2str(k) '. Pixels ' num2str(Pixels) ' with index p ' num2str(p)]);
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
                [detection,means,deviations] = detectForeground_adaptive(grayscale, means, deviations,al,rho);
%                 subplot(1,2,1)
                detection=imfill(detection,conn,'holes');
 %              imshow(logical(detection))
                detection=bwareaopen(detection,Pixels);
%                 subplot(1,2,2)
%                 imshow(logical(detection))
%                 drawnow();
                
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
            [precision(k),recall(k),accuracy(k),FMeasure(k)] = computeMetrics(TPTotal(k),FPTotal(k),TNTotal(k),FNTotal(k));
            
            if seq==1
                vec_seq1(p,k,1)=precision(k);
                vec_seq1(p,k,2)=recall(k);
                vec_seq1(p,k,3)=accuracy(k);
                vec_seq1(p,k,4)=FMeasure(k);
            elseif seq==2
                vec_seq2(p,k,1)=precision(k);
                vec_seq2(p,k,2)=recall(k);
                vec_seq2(p,k,3)=accuracy(k);
                vec_seq2(p,k,4)=FMeasure(k);
            elseif seq==3
                vec_seq3(p,k,1)=precision(k);
                vec_seq3(p,k,2)=recall(k);
                vec_seq3(p,k,3)=accuracy(k);
                vec_seq3(p,k,4)=FMeasure(k);
            end
        end
        
    end
end

toc

%AUC for every pixel parameter
ind=0;
for pixel=P
    ind=ind+1;
    auc_seq1(ind)=trapz(vec_seq1(ind,:,1),vec_seq1(ind,:,2));
    auc_seq2(ind)=trapz(vec_seq2(ind,:,1),vec_seq2(ind,:,2));
    auc_seq3(ind)=trapz(vec_seq3(ind,:,1),vec_seq3(ind,:,2));
end

save('w3t2-vec_seq1.mat','vec_seq1')
save('w3t2-vec_seq2.mat','vec_seq2')
save('w3t2-vec_seq3.mat','vec_seq3')
%AUC for every pixel parameter PLOT
figure()
plot(P,auc_seq1,'g')
hold on
plot(P,auc_seq2,'b')
hold on
plot(P,auc_seq3,'r')
hold off

title('AUC vs Pixels (P)'); xlabel('Pixels(P)'); ylabel('AUC')
legend('Highway (adaptive, rho=0.22)','Traffic (adaptive, rho=0.22)','Fall (adaptive,rho=0.11)');axis([0 1 0 1])


%Find best AUC separately for every sequence
ind=find(auc_seq1==max(max(auc_seq1)));
disp(['Best AUC for sequence 1 is ' num2str(max(max(auc_seq1))) ' with Pixel(P)' num2str(P(ind))] )
ind=find(auc_seq2==max(max(auc_seq2)));
disp(['Best AUC for sequence 2 is ' num2str(max(max(auc_seq2))) ' with Pixel(P)' num2str(P(ind))] )
ind=find(auc_seq3==max(max(auc_seq3)));
disp(['Best AUC for sequence 3 is ' num2str(max(max(auc_seq3))) ' with Pixel(P)' num2str(P(ind))] )

%Find best AUC as a mean of all sequences

mean_auc=(auc_seq1+auc_seq2+auc_seq3)/3;

ind=find(mean_auc==max(max(mean_auc)));
disp(['Best mean AUC ' num2str(max(max(mean_auc))) ' with Pixel(P)' num2str(P(ind))] )


