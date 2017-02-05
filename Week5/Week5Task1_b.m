%% pixel (i) 150 -> 700  = 100m

%% 225 -> 245   | 20
%% 245 -> 275   | 30
%% 275 -> 315   | 40
%% 315 -> 375   | 60
%% 375 -> 465   | 90
%% 465 -> 700   | 235
close all
clear all


x1=[77 126; 174 127; 18 309; 480 270];
x1 = makehomogeneous(x1');
x2 = [0 0; 270 0; 0 480; 480 270];
x2 = makehomogeneous(x2');
% x2 = [0 0 1; 0 1, 1; 1, 1, 1; 1, 0, 1];

H = homography2d(x1, x2);
video=1;
tic
%Paths to the input images and their groundtruth
sequencePath = {'datasets/ronda/01_twolanes/'} ;

%Initial and final frame of the sequence
iniFrame = [330];
endFrame = [1030];

% Create System objects used for detecting moving objects
blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea',100);

tracks = initializeTracks(); % Create an empty array of tracks.

nextId = 1; % ID of the next track
num_cars=0;

framesPassed = 0;
for seq=1
    disp(['Sequence ' num2str(seq)])
    %Train the background model with the first half of the sequence
    [means, deviations] = trainBackgroundModel_final(char(sequencePath(seq)), iniFrame(seq), 25);
    figure(4)
    subplot(1,2,1)
    imshow(uint8(means))
    subplot(1,2,2)
    imshow(uint8(deviations))
    
    na_means=means;
    na_deviations=deviations;
    
    
    %Define the range of alpha
    %Define the range of rho
    rho=0.2;
    alpha=5;
    
    %Get the information of the input and groundtruth images
    FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
    
    % k is used as an index to store information, in case alpha has 0, decimal or
    %negative values
    k=0;
    l=0;
    
    deviations=na_deviations;
    means=na_means;
    k=k+1;
    
     identification=zeros(1,100);
    counter=ones(1,100);
    velocity=cell(1,100);
    for r=1:100
        velocity{r}=0;
    end
    
    %Detect foreground objects in the second half of the sequence
    for i = iniFrame(seq)+25:endFrame(seq)
        %Read an image and convert it to grayscale
        image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
        imagenext= imread(strcat(char(sequencePath(seq)),FilesInput(i+1).name));
        imagenext = imresize(imagenext,0.25);
        grayscale = double(rgb2gray(image));
        grayscale = imresize(grayscale,0.25);
        
        old_means=means;
        old_deviations=deviations;
        %         if i == iniFrame(seq)+100
        %             Target = zeros(80,60);
        %             Idx = 0;
        %             [grayscale, Idx, Target] = stabilizeFrame(grayscale, true, Idx, Target);
        %         else
        %             [grayscale, Idx, Target] = stabilizeFrame(grayscale, false, Idx, Target);
        %         end
        %Detect foreground objects
        [detection,means,deviations] = detectForeground_adaptive(grayscale, means, deviations,alpha,rho);
        
        
        
        
        
        detection = imfill(detection, 'holes');
        detection = bwareaopen(detection,20);
        SE = strel('disk',5);
        
        detection=imclose(detection,SE);
        detection=imopen(detection,SE);
        detection = medfilt2(detection,[15,15]);
        
        %detection = bwareaopen(detection,100);
        detection(700/2:960/2,:)=0;
       % imagenext(700/2:704/2,:,1) = 255;
       % imagenext(700/2:704/2,:,2) = 0;
       % imagenext(700/2:704/2,:,3) = 0;
       
        detection_=RemovePerspective(detection,H,[480 270]);
        imagenext_=RemovePerspective(imagenext,H,[480 270]);
       
        detection_=logical(detection_(:,:,1));
        
        %Kalman Filter
        [area,centroids, bboxes] = step(blobAnalyzer,detection_);
        tracks=predictNewLocationsOfTracks(tracks);
        [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment(tracks,centroids,1);
        
        tracks=updateAssignedTracks(assignments,centroids,bboxes,tracks);
        tracks=updateUnassignedTracks(tracks,unassignedTracks);
        tracks=deleteLostTracks(tracks);
        [nextId,tracks]=createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId);
        
        %%%
        if framesPassed == 0
            previousTracks = tracks;
        end
        %%%
        
          for o=1:length(tracks)
            if identification(tracks(o).id)==0
                centroidsVel{tracks(o).id}(k,:)=[tracks(o).bbox(1)+(tracks(o).bbox(3)/2),tracks(o).bbox(2)+(tracks(o).bbox(4)/2)];
                identification(tracks(o).id)=1;
            else
                centroidsVel{tracks(o).id}=vertcat(centroidsVel{tracks(o).id}, [tracks(o).bbox(1)+(tracks(o).bbox(3)/2),tracks(o).bbox(2)+(tracks(o).bbox(4)/2)]);
            end
            time=6/30;
            pixel_meter=4.2/10;
            to_km=3.6;
            if length(centroidsVel{tracks(o).id})>5
                ref=centroidsVel{tracks(o).id}(counter(tracks(o).id),1);
%                 %% 225 -> 245   | 20 pixels = 8m
%                 %% 245 -> 275   | 30 pixels = 8m
%                 %% 275 -> 315   | 40 pixels = 8m
%                 %% 315 -> 375   | 60 pixels = 8m
%                 %% 375 -> 465   | 90 pixels = 8m
%                 %% 465 -> 700   | 235 pixels = 8m
% 
%                 if ref < 700/2 && ref > 465/2
%                     pixel_meter=8.5/235.0;
%                     
%                 elseif ref < 465/2 && ref > 375/2
%                     pixel_meter=8.5/90.0;
%                    
%                 elseif ref < 375/2 && ref > 315/2
%                     pixel_meter=8.5/60.0;
%                     
%                 elseif ref < 315/2 && ref > 275/2
%                     pixel_meter=8.5/40.0;
%                    
%                 elseif ref < 275/2 && ref > 245/2
%                     pixel_meter=8.5/30.0;
%                    
%                 elseif ref < 245/2 && ref > 225/2
%                     pixel_meter=8.5/20.0;
%                    
%                 end
pixel_meter=8.5/60;
                displacement=sqrt(double((centroidsVel{tracks(o).id}(counter(tracks(o).id),1)- centroidsVel{tracks(o).id}(counter(tracks(o).id)+5,1))^2 + (centroidsVel{tracks(o).id}(counter(tracks(o).id),2)- centroidsVel{tracks(o).id}(counter(tracks(o).id)+5,2))^2)) ;
                velocity{tracks(o).id}= ((displacement*pixel_meter)/time)*to_km;
                
                %Consider a valid car when we have to calculate velocity
                if  counter(tracks(o).id)==1
                    num_cars=num_cars+1;
                end
                    
                counter(tracks(o).id)=counter(tracks(o).id)+1;
            else
                
            end
        end

        
        
        %displayTrackingResults(imagenext,detection,tracks);
        imagenext(465:467,:,1) = 255;
        imagenext(465:467,:,2) = 0;
        imagenext(465:467,:,3) = 0;
        
        imagenext(375:377,:,1) = 255;
        imagenext(375:377,:,2) = 0;
        imagenext(375:377,:,3) = 0;
        
        imagenext(315:317,:,1) = 255;
        imagenext(315:317,:,2) = 0;
        imagenext(315:317,:,3) = 0;
        
        imagenext(315:317,:,1) = 255;
        imagenext(315:317,:,2) = 0;
        imagenext(315:317,:,3) = 0;
        
%         
%         if framesPassed == 1
%             framesPassed = 0;
%             ids = [tracks.id];
%             for i = 1:size(ids,2)
%                 t1 = previousTracks([previousTracks.id]==ids(i));
%                 if isempty(t1)
%                     continue;
%                 end
%                 t2 = tracks(i);
%                 pixelsMoved = t1.bbox(2)- t2.bbox(2);
%                 %% 225 -> 245   | 20 pixels = 8m
%                 %% 245 -> 275   | 30 pixels = 8m
%                 %% 275 -> 315   | 40 pixels = 8m
%                 %% 315 -> 375   | 60 pixels = 8m
%                 %% 375 -> 465   | 90 pixels = 8m
%                 %% 465 -> 700   | 235 pixels = 8m
% 
%                 %80/108 meters max in 1 frame
%                 if t1.bbox(2) < 700 && t1.bbox(2) > 465
%                     velocity = double(pixelsMoved) * (8.5/235.0) / (3.0/30.0) * 3.6
%                     if pixelsMoved > (80/108) * (235/8)
%                         display('VELOCITY LIMIT!')
%                     end
%                 elseif t1.bbox(2) < 465 && t1.bbox(2) > 375
%                     velocity = double(pixelsMoved)  * (8.5/90.0) / (3.0/30.0) * 3.6
%                     if pixelsMoved > (80/108) * (90/8)
%                         display('VELOCITY LIMIT!')
%                     end
%                 elseif t1.bbox(2) < 375 && t1.bbox(2) > 315
%                     velocity = double(pixelsMoved)  * (8.5/60.0) / (3.0/30.0) * 3.6
%                     if pixelsMoved > (80/108) * (60/8)
%                         display('VELOCITY LIMIT!')
%                     end
%                 elseif t1.bbox(2) < 315 && t1.bbox(2) > 275
%                     velocity = double(pixelsMoved)  * (8.5/40.0) / (3.0/30.0) * 3.6
%                     if pixelsMoved > (80/108) * (40/8)
%                         display('VELOCITY LIMIT!')
%                     end
%                 elseif t1.bbox(2) < 275 && t1.bbox(2) > 245
%                     velocity = double(pixelsMoved)  * (8.5/30.0) / (3.0/30.0) * 3.6
%                     if pixelsMoved > (80/108) * (30/8)
%                         display('VELOCITY LIMIT!')
%                     end
%                 elseif t1.bbox(2) < 245 && t1.bbox(2) > 225
%                     velocity = double(pixelsMoved)  * (8.5/20.0) / (3.0/30.0) * 3.6
%                     if pixelsMoved > (80/108) * (20/8)
%                         display('VELOCITY LIMIT!')
%                     end
%                 end
%             end
%             previousTracks = tracks;
%         else
%             framesPassed = framesPassed+1;
%         end
        
        displayTrackingResults(imagenext_,detection_,tracks,velocity);
        
        %Show the output of the detector
        %figure(2)
        %imshow(detection)
        
    end
    
end

disp(['Total number of cars in the road: ' int2str(num_cars)])
toc
