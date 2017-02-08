%Highway 1050 - 1350
%Fall 1460 - 1560
%Traffic 950 - 1050
%close all
clear all

video=0;
tic
%Paths to the input images and their groundtruth
sequencePath = {'datasets/highway/input/' 'datasets/traffic/input/'} ;
groundtruthPath = {'datasets/highway/groundtruth/' 'datasets/traffic/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950];
endFrame = [1350 1050];
predict_sp_seq1=[];
predict_sp_seq2=[];
max_pixel_distance=[240, 308];
distance=[90, 50];
for seq=1:2
    disp(['Sequence ' num2str(seq)])
    
    % Create System objects used for detecting moving objects
    blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', true, 'CentroidOutputPort', true, ...
        'MinimumBlobArea',70);
    figure;
    
    tracks = initializeTracks(); % Create an empty array of tracks.
    
    nextId = 1; % ID of the next track
    
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
    % numAlphas = size(alpha,2);
    % numRhos= size(rho,2);
    %
    % precision = zeros(1,numAlphas); recall = zeros(1,numAlphas);
    % accuracy = zeros(1,numAlphas); FMeasure = zeros(1,numAlphas);
    %
    % TPTotal=zeros(1,numAlphas);FPTotal=zeros(1,numAlphas);
    % TNTotal=zeros(1,numAlphas);FNTotal=zeros(1,numAlphas);
    
    %Get the information of the input and groundtruth images
    FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
    % FilesGroundtruth = dir(char(strcat(groundtruthPath(seq), '*png')));
    
    % k is used as an index to store information, in case alpha has 0, decimal or
    %negative values
    % k=0;
    % l=0;
    
    %Chose type of SE
    SE = strel('line',20,30);  %len es llargada i deg els graus
    conn=4; %connectivity
    
    %Kalman Filter
    %kalmanFilter = []; isTrackInitialized = false;
    al=3;
    deviations=na_deviations;
    means=na_means;
    %k=k+1;
    iter=1;
    %Detect foreground objects in the second half of the sequence
    for i = iniFrame(seq)+(endFrame(seq)-iniFrame(seq))/2+1:endFrame(seq)-1
        %Read an image and convert it to grayscale
        image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
        imagenext= imread(strcat(char(sequencePath(seq)),FilesInput(i+1).name));
        grayscale = double(rgb2gray(image));
        %Read the groundtruth image
        %groundtruth = readGroundtruth(char(strcat(groundtruthPath(seq),FilesGroundtruth(i).name)));
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
        [area,centroids, bboxes] = step(blobAnalyzer,detection);
        tracks=predictNewLocationsOfTracks(tracks);
        [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment(tracks,centroids);
        
        tracks=updateAssignedTracks(assignments,centroids,bboxes,tracks);
        tracks=updateUnassignedTracks(tracks,unassignedTracks);
        tracks=deleteLostTracks(tracks);
        [nextId,tracks]=createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId);
        size(tracks)
        displayTrackingResults(imagenext,detection,tracks);
        
        %             [area,detectedLocation,bbox] = step(blobAnalyzer,detection);
        %             isObjectDetected = size(detectedLocation, 1) > 0;
        %             if isObjectDetected
        %                     for j=1:size(detectedLocation,1)
        %                         kalmanFilter = configureKalmanFilter('ConstantAcceleration',...
        %                         detectedLocation(j,:), [1 1 1]*1e5, [25, 10, 10], 25);
        %                         isTrackInitialized = true;
        %                         predict(kalmanFilter);
        %                         trackedLocation = correct(kalmanFilter, detectedLocation(j,:));
        %                         x{j}=trackedLocation(1);
        %                         y{j}=trackedLocation(2);
        %                         h=sqrt(double(area(j)));
        %                         rectangle = [x{j}-h/2 y{j}-h/2, h,h];
        %                         %Predict speed
        %                         if seq==1
        %                         predict_sp_seq1(j,iter,1)=x{j};
        %                         predict_sp_seq1(j,iter,2)=y{j};
        %                         elseif seq==2
        %                         predict_sp_seq2(j,iter,1)=x{j};
        %                         predict_sp_seq2(j,iter,2)=y{j};
        %                         end
        %                         iter=iter+1;
        %                         for k=1:length(rectangle)
        %                             positions(j,k)=rectangle(k);
        %                         end
        %                         label_str{j} = ['Car: ' num2str(j)];
        %                     end
        %             else
        %                     trackedLocation = predict(kalmanFilter);
        %                     label = 'Predicted';
        %                     positions= [0,0,0,0];
        %                     label_str='No car';
        %             end
        %             colorImage = insertObjectAnnotation(imagenext,'rectangle',...
        %                 positions,label_str,'Color','red');
        %             imshow(colorImage)
        %
        %             clear label_str
        %             clear positions
    end
end

%Predict speeds

s1=size(predict_sp_seq1);
fps=20;
for i=1:s1(1)
    v=find(predict_sp_seq1(i,:,1)~=0);
    trajectory=[predict_sp_seq1(i,v(end),1)-predict_sp_seq1(i,v(1),1),predict_sp_seq1(i,v(end),2)-predict_sp_seq1(i,v(1),2)]
    final_speed_seq1(i)=norm(trajectory)/((v(end)-v(1))/fps);
end

s2=size(predict_sp_seq2);
fps=20;
for i=1:s2(1)
    v=find(predict_sp_seq2(i,:,1)~=0);
    trajectory=[predict_sp_seq2(i,v(end),1)-predict_sp_seq2(i,v(1),1),predict_sp_seq2(i,v(1),2)-predict_sp_seq2(i,v(1),2)];
    final_speed_seq2(i)=norm(trajectory)/((v(end)-v(1))/fps);
end
