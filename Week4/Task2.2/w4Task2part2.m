close all
clear all

video=0;
tic
%Paths to the input images and their groundtruth
sequencePath = {'../Archivos/traffic/traffic/input/'} ;
groundtruthPath = {'../Archivos/traffic/traffic/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [950];
endFrame = [1050];

disp(['Sequence Traffic'])

[means, deviations] = trainBackgroundWithStabilizationPointFeature(char(sequencePath), char(groundtruthPath), iniFrame, (endFrame-iniFrame)/2);
 na_means=means;
 na_deviations=deviations;
 
%Define the range of alpha
alpha=0:30;
rho=0.22; %Best parameter from previous weeks

%Allocate memory for variables
numAlphas = size(alpha,2);
numRhos= size(rho,2);

precision = zeros(numRhos,numAlphas); recall = zeros(numRhos,numAlphas); 
accuracy = zeros(numRhos,numAlphas); FMeasure = zeros(numRhos,numAlphas);

TPTotal=zeros(numRhos,numAlphas);FPTotal=zeros(numRhos,numAlphas);
TNTotal=zeros(numRhos,numAlphas);FNTotal=zeros(numRhos,numAlphas);

%Get the information of the input and groundtruth images
FilesInput = dir(char(strcat(sequencePath, '*jpg')));
FilesGroundtruth = dir(char(strcat(groundtruthPath, '*png')));

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



if video==1 
    NFrames=length(FilesInput);
    figure();
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
    F(NFrames) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('Fall-task2_rho08.avi');
    v.FrameRate = 10;
    open(v)
end

%Read the first image and convert it to grayscale
image = imread(strcat(char(sequencePath),FilesInput(iniFrame+(endFrame-iniFrame)/2).name));
I=imsharpen(image,'Radius',20,'Amount',15);
grayscaleBefore=rgb2gray(I);
pointsBefore = detectFASTFeatures(grayscaleBefore);
j=0;

for al = 4
    deviations=na_deviations;
    means=na_means;
    k=k+1
    %Detect foreground objects in the second half of the sequence
        for i = iniFrame+(endFrame-iniFrame)/2+1:endFrame
            j=j+1
            %Read an image and convert it to grayscale
            image = imread(strcat(char(sequencePath),FilesInput(i).name));
            I=imsharpen(image,'Radius',20,'Amount',15);
            grayscaleAfter=rgb2gray(I);
            %Read the groundtruth image
            groundtruth = readGroundtruth(char(strcat(groundtruthPath,FilesGroundtruth(i).name)));  
            %%%%% --> better results if we count the hard shadows as foreground
            %%%%% groundtruth = double(imread(strcat(groundtruthPath,FilesGroundtruth(i).name))) > 169;
            old_means=means;
            old_deviations=deviations;
            
            %Extract corners
            pointsAfter = detectFASTFeatures(grayscaleAfter);
            
            %Estract FREAK descriptors
            [featuresA, pointsA] = extractFeatures(grayscaleAfter, pointsAfter);
            [featuresB, pointsB] = extractFeatures(grayscaleBefore, pointsBefore);
            
            %match the features from both images
            indexPairs = matchFeatures(featuresA, featuresB);
            pointsA = pointsA(indexPairs(:, 1), :);
            pointsB = pointsB(indexPairs(:, 2), :);
            
            if length(indexPairs)>3
            %grayscale = interp2((grayscaleAfter), x1+a, y1+b);
                [tform, pointsBm, pointsAm] = estimateGeometricTransform(...
                pointsB, pointsA, 'similarity');
            
                grayscaleMoved = imwarp(grayscaleAfter, tform, 'OutputView', imref2d(size(grayscaleAfter)));
                pointsMoved = transformPointsForward(tform, pointsAm.Location);
            
                %recompute the before status
                grayscaleBefore=grayscaleMoved;
                pointsBefore = detectFASTFeatures(grayscaleBefore);
            
                gray=double(grayscaleMoved);
            else
                gray=double(grayscaleAfter);
                grayscaleBefore=grayscaleAfter;
            end
            %Detect foreground objects
            [detection,means,deviations] = detectForeground_adaptive(gray, means, deviations,al,rho);
            %[detectionold, ~,~]=detectForeground_adaptive(grayscaleBefore,means,deviations,al,rho);
            
            %detection(grayscale==0)=0;
            
            %Connectivity
            detection=imfill(detection,conn,'holes');
            
            %Choose Morph Operator
            %detection=imclose(detection,SE);   %closing
            detection=imopen(detection,SE);    %opening
            %detection=imdilate(detection,SE);   %dilation
            %detection=imerode(detection,SE);   %erosion
            
%             figure(1)
%             imshow(detection)
%             figure(2)
%             imshow(detectionold)
%             figure(3)
%             imshow(groundtruth)
            
            %Compute the performance of the detector for the whole sequence
            [TP,FP,TN,FN] = computePerformance(groundtruth, detection);
            TPTotal(k)=TPTotal(k)+TP;
            FPTotal(k)=FPTotal(k)+FP;
            TNTotal(k)=TNTotal(k)+TN;
            FNTotal(k)=FNTotal(k)+FN;
        
            if video==1
                subplot(1,3,1); imshow(uint8(gray));
                title('Sequence')
                subplot(1,3,2); imshow(logical((detection)));
                title('Highway Seq. 8th Connectivity')
                subplot(1,3,3); imshow(groundtruth);
                title ('Background mean')
                %subplot(2,3,5); imagesc(uint8(old_means-means));
                %colorbar;
                %title('Mean difference between frames')
                %subplot(2,3,3); imshow(uint8(deviations),[min(min(deviations)) max(max(deviations))]);
                %title ('Background deviation')     
                %subplot(2,3,6); imagesc(uint8(old_deviations-deviations));
                %colorbar;
                %title('Deviation difference between frames')
                drawnow();
             %Save the figure in a video
                if i==1349
                else
                    F(i) = getframe(gcf);
                    writeVideo(v,F(i));
                end
            end   
            
        end
        
        %Compute the performance of the detector for the whole sequence
    [precision(k),recall(k),accuracy(k),FMeasure(k)] = computeMetrics(TPTotal(k),FPTotal(k),TNTotal(k),FNTotal(k));
          
    vec(1,k,1)=precision(k);
    vec(1,k,2)=recall(k);
    vec(1,k,3)=accuracy(k);
    vec(1,k,4)=FMeasure(k);
end


if video==1
    %Close video object
    close(v)
end
toc
%Precision
figure(); 
for seq=1
    plot(alpha, vec(seq,:,1))
    hold on
end
hold off
title('Precision for the Traffic sequences'); xlabel('Alpha'); ylabel('Precision')
legend('Traffic'); ylim([0 1])

%Recall
figure(); 
for seq=1
    plot(alpha, vec(seq,:,2))
    hold on
end
hold off
title('Recall for the Traffic sequences'); xlabel('Alpha'); ylabel('Recall')
legend('Traffic'); ylim([0 1])

%Precision-Recall
figure()
for seq=1
    plot(vec(seq,:,2),vec(seq,:,1))
    hold on
end
hold off
title('P-R curve for the Traffic sequences'); xlabel('Recall'); ylabel('Precision')
legend('Traffic'); axis([0 1 0 1])

%F Measure
figure();
for seq=1
    plot(alpha, vec(seq,:,4))
    hold on;
end
hold off;
title('Fmeasure for the Traffic sequences'); xlabel('Alpha'); ylabel('Fmeasure')
legend('Traffic'); ylim([0 1])

for seq=1
    [F1,alphas]=max(vec(seq,:,4));
    disp(['F1 & alpha for sequence Traffic ' ': ' num2str(F1) ', ' num2str(alphas-1)] )
end

for seq=1
    auc(seq)=trapz(vec(seq,:,1),vec(seq,:,2));
    disp(['AUC for sequence Traffic ' ': ' num2str(auc(seq))] )
end

disp(['Median AUC : ' num2str((sum(auc))/3)] )
            

 
 