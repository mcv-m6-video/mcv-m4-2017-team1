%Highway 1050 - 1350 
%Fall 1460 - 1560 
%Traffic 950 - 1050
%close all
clear all

video=0;
tic
%Paths to the input images and their groundtruth
sequencePath = {'../Archivos/highway/input/' '../Archivos/traffic/traffic/input/'} ;
groundtruthPath = {'../Archivos/highway/groundtruth/' '../Archivos/traffic/traffic/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950];
endFrame = [1350 1050];

for seq=1:2
    disp(['Sequence ' num2str(seq)])
%Train the background model with the first half of the sequence
[means, deviations] = trainBackgroundModelAllPix(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);
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
SE = strel('line',20,30);  %len es llargada i deg els graus
conn=4; %connectivity

%Kalman Filter
kalmanFilter = []; isTrackInitialized = false;
blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
                'MinimumBlobArea',70);

    for al = 3
        deviations=na_deviations;
        means=na_means;
        k=k+1;
            %Detect foreground objects in the second half of the sequence
        for i = iniFrame(seq)+(endFrame(seq)-iniFrame(seq))/2+1:endFrame(seq)-1
            %Read an image and convert it to grayscale
            image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
            imagenext= imread(strcat(char(sequencePath(seq)),FilesInput(i+1).name));
            grayscale = double(rgb2gray(image));
            %Read the groundtruth image
            groundtruth = readGroundtruth(char(strcat(groundtruthPath(seq),FilesGroundtruth(i).name)));  
            %%%%% --> better results if we count the hard shadows as foreground
            %%%%% groundtruth = double(imread(strcat(groundtruthPath,FilesGroundtruth(i).name))) > 169;
            old_means=means;
            old_deviations=deviations;
      
            %Detect foreground objects
            [detection,means,deviations] = detectForeground_adaptive(grayscale, means, deviations,al,rho);
            
            %Choose Morph Operator
            detection=imfill(detection,conn,'holes');
            detection=imopen(detection,SE);    %opening
            
            %Kalman Filter
            [area,detectedLocation,bbox] = step(blobAnalyzer,detection);
            isObjectDetected = size(detectedLocation, 1) > 0;
            if isObjectDetected
                    for j=1:size(detectedLocation,1)
                        kalmanFilter = configureKalmanFilter('ConstantAcceleration',...
                        detectedLocation(j,:), [1 1 1]*1e5, [25, 10, 10], 25);
                        isTrackInitialized = true;
                        predict(kalmanFilter);
                        trackedLocation = correct(kalmanFilter, detectedLocation(j,:));
                        x{j}=trackedLocation(1);
                        y{j}=trackedLocation(2);
                        h=sqrt(double(area(j)));
                        rectangle = [x{j}-h/2 y{j}-h/2, h,h];
                        for k=1:length(rectangle)
                            positions(j,k)=rectangle(k);
                        end
                        label_str{j} = ['Car: ' num2str(j)];
                    end
            else
                    trackedLocation = predict(kalmanFilter);
                    label = 'Predicted';
                    positions= [0,0,0,0];
                    label_str='No car';
            end 
            colorImage = insertObjectAnnotation(imagenext,'rectangle',...
                positions,label_str,'Color','red');
            imshow(colorImage)
                                   
            clear label_str
            clear positions
        end
    end
end

