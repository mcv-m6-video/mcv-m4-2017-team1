close all
clear all
video=1;

if video==1
    ind=1;
%    F(NFrames) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('RoadTraffic_surv.avi');
    v.FrameRate = 10;
    open(v)
end
%x1=[77 126; 174 127; 18 309; 480 270];

x1=[80 126; 161 127; 18 309; 480 270];
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
endFrame = [530];

% Create System objects used for detecting moving objects
blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', true, 'CentroidOutputPort', true, ...
    'MinimumBlobArea',100);

tracks = initializeTracks(); % Create an empty array of tracks.

nextId = 1; % ID of the next track
num_cars=0;
speed_limit_pictures={};
speed_limit_id=[];
speed_limit_labels=[];

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
        image = imresize(image,0.25);
        imagenext= imread(strcat(char(sequencePath(seq)),FilesInput(i+1).name));
        imagenext = imresize(imagenext,0.25);
        grayscale = double(rgb2gray(image));
        %grayscale = imresize(grayscale,0.25);
        
        old_means=means;
        old_deviations=deviations;

        %Detect foreground objects

        [detection,means,deviations] = detectForeground_adaptive(grayscale, means, deviations,alpha,rho);


        detection = imfill(detection, 'holes');
        detection = bwareaopen(detection,20);
        SE = strel('disk',5);
        
        detection=imclose(detection,SE);
        detection=imopen(detection,SE);
        detection = medfilt2(detection,[15,15]);

        detection_=RemovePerspective(detection,H,[480 270]);

        image_=RemovePerspective(image,H,[480 270]);
 
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
     

        for o=1:length(tracks)
            if identification(tracks(o).id)==0
                %centroidsVel{tracks(o).id}(k,:)=[tracks(o).bbox(1)+(tracks(o).bbox(3)/2),tracks(o).bbox(2)+(tracks(o).bbox(4)/2)];
                centroidsVel{tracks(o).id}(k,:)=[tracks(o).bbox(1),tracks(o).bbox(2)];
                identification(tracks(o).id)=1;
            else
                %centroidsVel{tracks(o).id}=vertcat(centroidsVel{tracks(o).id}, [tracks(o).bbox(1)+(tracks(o).bbox(3)/2),tracks(o).bbox(2)+(tracks(o).bbox(4)/2)]);
                centroidsVel{tracks(o).id}=vertcat(centroidsVel{tracks(o).id}, [tracks(o).bbox(1),tracks(o).bbox(2)]);

            end
            
            %pixel_meter=4.2/10;
            pixel_meter=9/75;
            %pixel_meter=3/46.5;
            to_km=3.6;
            wait_frames = 3;
            time=wait_frames/30;
            if length(centroidsVel{tracks(o).id})>wait_frames-1
                ref=centroidsVel{tracks(o).id}(counter(tracks(o).id),1);
             
                displacement=sqrt(double((centroidsVel{tracks(o).id}(counter(tracks(o).id),1)- centroidsVel{tracks(o).id}(counter(tracks(o).id)+wait_frames-1,1))^2 + (centroidsVel{tracks(o).id}(counter(tracks(o).id),2)- centroidsVel{tracks(o).id}(counter(tracks(o).id)+wait_frames-1,2))^2)) ;
                velocity{tracks(o).id}= ((displacement*pixel_meter)/time)*to_km;
                
                %Consider a valid car when we have to calculate velocity
                if  counter(tracks(o).id)==1
                    num_cars=num_cars+1;
                end
                
                counter(tracks(o).id)=counter(tracks(o).id)+1;
            else
                
            end
        end
        
          [speed_limit_pictures,speed_limit_id,speed_limit_labels]= displayTrackingResults(image_,detection_,tracks,velocity,speed_limit_pictures,speed_limit_id,speed_limit_labels);
        if video==1
        F(ind) = getframe(gcf);
        writeVideo(v,F(ind));
        ind=ind+1;
        end
        

        
        %Show the output of the detector
        %figure(2)
        %imshow(detection)
        
    end
    
end
if video==1
    %Close video object
    close(v)
end

disp(['Total number of cars in the road: ' int2str(num_cars)])
toc
