function [newMean, newDev] = trainBackgroundWithStabilizationPointFeature(sequencePath,groundtruthPath, iniFrame, numFrames)

%Get the information of the input and groundtruth images
FilesInput = dir(strcat(sequencePath, '*jpg'));
%FilesGroundtruth = dir(strcat(groundtruthPath, '*png'));

%Read the first image and convert it to grayscale
image = imread(strcat(sequencePath,FilesInput(iniFrame).name));
I=imsharpen(image,'Radius',20,'Amount',15);
grayscaleBefore=rgb2gray(I);
pointsBefore = detectFASTFeatures(grayscaleBefore);
j=0;

%Create a mask of the pixels to take into account in the computation of the
%mean and deviation (those that belong to the background, with a value of 0)
%mask = double(imread(strcat(groundtruthPath,FilesGroundtruth(iniFrame).name)))==0;
%Uncomment to use all the pixels to compute the mean and deviation
mask = ones(size(grayscaleBefore));

%Initialize the mean and deviation of each pixel, only using those pixels
%where the mask is 1 (pixels belonging to the background, with value 0)
oldMean = double(grayscaleBefore).*mask;
oldDev = zeros(size(oldMean));

%Initialize a counter of the number of elements used to compute the mean
%for each pixel
newN = mask;

%Initialize variables to plot the changes in value, mean and deviation of a pixel
pixelGray=[]; pixelMean=[]; pixelDev=[];
pixel = [200,65]; %75,155
% figure(1)


for i = iniFrame+1:iniFrame+numFrames
    %Read an image and convert it to grayscale
            image = imread(strcat(sequencePath,FilesInput(i).name));
            I=imsharpen(image,'Radius',20,'Amount',15);
            grayscaleAfter=rgb2gray(I);
            pointsAfter = detectFASTFeatures(grayscaleAfter);
    
    %Create a mask of the pixels to take into account in the computation of the
    %mean and deviation
    %mask = double(imread(strcat(groundtruthPath,FilesGroundtruth(i).name)))==0;
    %Uncomment to use all the pixels to compute the mean and deviation
    mask = ones(size(grayscaleAfter));
    
    %The number of frames taken into account to compute the mean and
    %deviation of a pixel increases if the pixel belongs to the background
    newN = newN + mask;
    
    %Stabilize the grayscale image
            [featuresA, pointsA] = extractFeatures(grayscaleAfter, pointsAfter);
            [featuresB, pointsB] = extractFeatures(grayscaleBefore, pointsBefore);
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
    
    %Compute the mean and deviation when we add a new element
    newMean = add2Mean(oldMean, gray, newN,mask);
    newDev = add2StdDev(oldMean, oldDev, gray, newMean, newN,mask);

    %Save the values of mean and deviation needed for the next iteration
    oldMean = newMean;
    oldDev = newDev;

    %Plot the evolution of the gray value, mean and deviation of a pixel
    pixelGray = [pixelGray gray(pixel(1),pixel(2))]; 
    pixelMean = [pixelMean newMean(pixel(1),pixel(2))];
    pixelDev = [pixelDev newDev(pixel(1),pixel(2))];

%     plot(1:i-iniFrame,pixelMean)
%     hold on;
%     plot(1:i-iniFrame,pixelGray)
%     plot(1:i-iniFrame,pixelDev)
%     hold off;
%     drawnow();
end

end