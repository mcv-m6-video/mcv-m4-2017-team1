%Highway 1050 - 1350
%Fall 1460 - 1560
%Traffic 950 - 1050
close all


video=0;
stabilization=1;
tic
%Paths to the input images and their groundtruth
sequencePath = {'datasets/highway/input/' 'datasets/traffic/input/' 'datasets/fall/input/'} ;
groundtruthPath = {'datasets/highway/groundtruth/' 'datasets/traffic/groundtruth/' 'datasets/fall/groundtruth/'};

%Initial and final frame of the sequence
iniFrame = [1050 950 1460];
endFrame = [1350 1050 1560];


for iter=1:2
    if iter ==1
        stabilization = 1;
    else
        stabilization = 0;
        sequencePath = {'datasets/highway/input/' 'datasets/trafficStab/input/' 'datasets/fall/input/'} ;
        groundtruthPath = {'datasets/highway/groundtruth/' 'datasets/trafficStab/groundtruth/' 'datasets/fall/groundtruth/'};
        iniFrame = [1050 1 1460];
        endFrame = [1350 100 1560];
    end
    
    for seq=2
        disp(['Sequence ' num2str(seq)])
        
        if iter ==1
            [means, deviations] = trainBackgroundModelAllPix(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);
        else
            [means, deviations] = trainBackgroundModelAllPix_forMatlab(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);
        end
    
        %Train the background model with the first half of the sequence
        %[means, deviations] = trainBackgroundModelAllPix(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);
        %[means, deviations] = trainBackgroundWithStabilization(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);

        na_means=means;
        na_deviations=deviations;
        
        
        %Define the range of alpha
        %Define the range of rho
        if seq==1
            rho=0.22;
            alpha=0:30;
        elseif seq==2
            rho=0.22;
            alpha=0:30;
        elseif seq==3
            rho=0.11;
            alpha=0:30;
        end
        
        %Allocate memory for variables
        numAlphas = size(alpha,2);
        numRhos= size(rho,2);
        
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
        l=0;
        
        %Chose type of SE
        %SE = strel('square',10); %5=width
        %SE = strel('square',5);
        %SE = strel('square',20);
        %SE = strel('disk',5); %5=Radius
        %SE = strel('disk',10);
        %SE = strel('disk',20);
        %SE = strel('diamond',10 ); %R=distance from the SE to the points of the diamond
        SE = strel('line',20,30);  %len es llargada i deg els graus
        
        %Chose Connectivity
        conn=4;
        %conn=8
        
        for al = alpha
            al
            deviations=na_deviations;
            means=na_means;
            k=k+1;
            %Detect foreground objects in the second half of the sequence
            for i = 51:100
                %Read an image and convert it to grayscale
                image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
                if iter ==1
                    grayscale = double(rgb2gray(image));    
                    if i == iniFrame(seq)+(endFrame(seq)-iniFrame(seq))/2+1
                        previousFrame = grayscale;
                    end
                else
                    grayscale = double(image); 
                    if i == 51
                        previousFrame = grayscale;
                    end
                end
        
                %grayscale = double(image); % double(rgb2gray(image));
                %Read the groundtruth image
                groundtruth = readGroundtruth(char(strcat(groundtruthPath(seq),FilesGroundtruth(i).name)));
                
                old_means=means;
                old_deviations=deviations;
                
                
                
                if stabilization==1
                    [resultImage, motion_i, motion_j] = blockMatching_b(previousFrame, grayscale);

                    moi = reshape(motion_i, 1, size(motion_i,1)*size(motion_i,2));
                    moj = reshape(motion_j, 1, size(motion_j,1)*size(motion_j,2));

                    mo_i = median(moi);
                    mo_j = median(moj);

                    trans = imtranslate(grayscale,[mo_j,mo_i],'FillValues',111);
                    groundtruth = imtranslate(groundtruth,[mo_j,mo_i],'FillValues',111);
                    previousFrame = trans;
                else
                    trans = grayscale;
                end
                %Detect foreground objects
                [detection,means,deviations] = detectForeground_adaptive(trans, means, deviations,al,rho);
               
                detection(groundtruth==111) = 111;                
                %Connectivity
                if iter==2
                    %detection=imfill(detection,conn,'holes');
                    %Choose Morph Operator
                    %%detection=imclose(detection,SE);   %closing
                    %detection=imopen(detection,SE);    %opening
                end
                %detection=imdilate(detection,SE);   %dilation
                %detection=imerode(detection,SE);   %erosion
                
                %Compute the performance of the detector for the whole sequence
                [TP,FP,TN,FN] = computePerformance(groundtruth, detection);
                TPTotal(k)=TPTotal(k)+TP;
                FPTotal(k)=FPTotal(k)+FP;
                TNTotal(k)=TNTotal(k)+TN;
                FNTotal(k)=FNTotal(k)+FN;
                
                %Show the output of the detector
                %figure(2)
                %subplot(1,3,1)
                %imshow(uint8(trans))
                %subplot(1,3,2)
                %imshow(groundtruth)
                %subplot(1,3,3)
                %imshow(detection)
                %drawnow()
            end
            %Compute the performance of the detector for the whole sequence
            [precision(k),recall(k),accuracy(k),FMeasure(k)] = computeMetrics(TPTotal(k),FPTotal(k),TNTotal(k),FNTotal(k));
            
            if (iter==1)
                vec(seq,k,1)=precision(k);
                vec(seq,k,2)=recall(k);
                vec(seq,k,3)=accuracy(k);
                vec(seq,k,4)=FMeasure(k);
            elseif iter==2
                
                vec_new(seq,k,1)=precision(k);
                vec_new(seq,k,2)=recall(k);
                vec_new(seq,k,3)=accuracy(k);
                vec_new(seq,k,4)=FMeasure(k);
            end
        end
    end
    
end
toc
% %Precision
% figure();
% for seq=1:numel(iniFrame)
%     plot(alpha, vec(seq,:,1))
%     hold on
% end
% hold off
% title('Precision for the 3 sequences'); xlabel('Alpha'); ylabel('Precision')
% legend('Highway','Traffic','Fall'); ylim([0 1])
%
% %Recall
% figure();
% for seq=1:numel(iniFrame)
%     plot(alpha, vec(seq,:,2))
%     hold on
% end
% hold off
% title('Recall for the 3 sequences'); xlabel('Alpha'); ylabel('Recall')
% legend('Highway','Traffic','Fall'); ylim([0 1])
%
% %Precision-Recall
% figure()
% for seq=1:numel(iniFrame)
%     plot(vec(seq,:,2),vec(seq,:,1))
%     hold on
% end
% hold off
% title('P-R curve for the 3 sequences'); xlabel('Recall'); ylabel('Precision')
% legend('Highway','Traffic','Fall'); axis([0 1 0 1])
%
% %F Measure
% figure();
% for seq=1:numel(iniFrame)
%     plot(alpha, vec(seq,:,4))
%     hold on;
% end
% hold off;
% title('Fmeasure for the 3 sequences'); xlabel('Alpha'); ylabel('Fmeasure')
% legend('Highway','Traffic','Fall'); ylim([0 1])
%
% for seq=1:3
%     [F1,alphas]=max(vec(seq,:,4));
%     disp(['F1 & alpha for sequence ' num2str(seq) ': ' num2str(F1) ', ' num2str(alphas-1)] )
% end
%
% for seq=1:3
%     auc(seq)=trapz(vec(seq,:,1),vec(seq,:,2));
%     disp(['AUC for sequence ' num2str(seq) ': ' num2str(auc(seq))] )
% end
%
% disp(['Median AUC : ' num2str((sum(auc))/3)] )

figure();
plot(vec(2,:,2),vec(2,:,1))
hold on
plot(vec_new(2,:,2),vec_new(2,:,1))
hold off
title('Traffic P-R curve'); xlabel('Recall'); ylabel('Precision')
legend('Stabilized','Not stabilized'); axis([0 1 0 1])


%F Measure
figure();
plot(alpha, vec(2,:,4))
hold on;
plot(alpha, vec_new(2,:,4))
hold off;
title('Fmeasure'); xlabel('Alpha'); ylabel('Fmeasure')
legend('Stabilized','Not stabilized'); ylim([0 1])


auc=trapz(vec(2,:,1),vec(2,:,2))
auc_notstab=trapz(vec_new(2,:,1),vec_new(2,:,2))