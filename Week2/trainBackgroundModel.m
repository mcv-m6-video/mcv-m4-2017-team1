function [newMean, newDev] = trainBackgroundModel(sequencePath, groundtruthPath, iniFrame, numFrames)

%Plot boolean
show_plot = 0;

%Get the information of the input and groundtruth images
FilesInput = dir(strcat(sequencePath, '*jpg'));
FilesGroundtruth = dir(strcat(groundtruthPath, '*png'));

%Read the first image and convert it to grayscale
image = imread(strcat(sequencePath,FilesInput(iniFrame).name));
grayscale = double(rgb2gray(image));
%Create a mask of the pixels to take into account in the computation of the
%mean and deviation (those that belong to the background, with a value of 0)
%mask = double(imread(strcat(groundtruthPath,FilesGroundtruth(iniFrame).name)))==0;
%Uncomment to use all the pixels to compute the mean and deviation
mask = ones(size(grayscale));

%Initialize the mean and deviation of each pixel, only using those pixels
%where the mask is 1 (pixels belonging to the background, with value 0)
oldMean = grayscale.*mask;
oldDev = zeros(size(oldMean));

%Initialize a counter of the number of elements used to compute the mean
%for each pixel
newN = mask;

%Initialize variables to plot the changes in value, mean and deviation of a pixel
pixel = [200,65]; %75,155
pixelGray=grayscale(200,65); pixelMean=pixelGray; pixelDev=0;

if show_plot==1
    figure;
end

for i = iniFrame+1:iniFrame+numFrames
    %Read an image and convert it to grayscale
    image = imread(strcat(sequencePath,FilesInput(i).name));
    grayscale = double(rgb2gray(image));
    
    if show_plot==1
        subplot(2,1,1)
        imshow(uint8(grayscale(120:240,:,:)))
        rectangle('Position',[61,196-120,8,8],'EdgeColor','r')
        title('Zoom of frame, with evaluated pixel inside the red rectangle')
        drawnow();
    end
    %Create a mask of the pixels to take into account in the computation of the
    %mean and deviation
    %mask = double(imread(strcat(groundtruthPath,FilesGroundtruth(i).name)))==0;
    %Uncomment to use all the pixels to compute the mean and deviation
    mask = ones(size(grayscale));
    
    %The number of frames taken into account to compute the mean and
    %deviation of a pixel increases if the pixel belongs to the background
    newN = newN + mask;
    
    %Compute the mean and deviation when we add a new element
    newMean = add2Mean(oldMean, grayscale, newN,mask);
    newDev = add2StdDev(oldMean, oldDev, grayscale, newMean, newN,mask);

    %Save the values of mean and deviation needed for the next iteration
    oldMean = newMean;
    oldDev = newDev;

    %Plot the evolution of the gray value, mean and deviation of a pixel
    pixelGray = [pixelGray grayscale(pixel(1),pixel(2))]; 
    pixelMean = [pixelMean newMean(pixel(1),pixel(2))];
    pixelDev = [pixelDev newDev(pixel(1),pixel(2))];

    if show_plot==1
        subplot(2,1,2)
        plot(iniFrame:i,pixelMean)
        hold on;
        plot(iniFrame:i,pixelGray)
        plot(iniFrame:i,pixelDev)
        hold off;
        drawnow();
    end
 
end
    
if show_plot==1
    legend('Pixel''s mean','Pixel'' gray value','Pixel''s standard deviation')
    xlabel('# frame')
    ylabel('Pixel value')
    title('Pixel evolution along the sequence')
    drawnow();
end
