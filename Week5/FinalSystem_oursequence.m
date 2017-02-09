close all
clear all

video=0;

if video==1
    ind=1;
    v = VideoWriter('RoadTraffic_surv_test.avi');
    v.FrameRate = 10;
    open(v)
    figure;
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
end

%Variables for homography
x1=[80 126; 161 127; 18 309; 480 270];
x1 = makehomogeneous(x1');
x2 = [0 0; 270 0; 0 480; 480 270];
x2 = makehomogeneous(x2');
%x1=[77 126; 174 127; 18 309; 480 270];
% x2 = [0 0 1; 0 1, 1; 1, 1, 1; 1, 0, 1];

H = homography2d(x1, x2);
T=inv(H);


tic
%Paths to the input images
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
speed_limit_labels={};
speed_limit_num_frame=[];

for seq=1
    
    disp(['Sequence ' num2str(seq)])
    
    %Train the background model with the first half of the sequence
    [means, deviations] = trainBackgroundModel_final(char(sequencePath(seq)), iniFrame(seq), 25);
    
    % Shadow Removal
    %     [meansrgb, deviationsrgb] = trainBackgroundModelColor_final(char(sequencePath(seq)), iniFrame(seq), 25);
    %     meansrgI = meansrgb;
    %     meansrgI(:,:,1) = meansrgI(:,:,1)./(meansrgI(:,:,1)+meansrgI(:,:,2)+meansrgI(:,:,3));
    %     meansrgI(:,:,2) = meansrgI(:,:,2)./(meansrgI(:,:,1)+meansrgI(:,:,2)+meansrgI(:,:,3));
    %     meansrgI(:,:,3) = (meansrgI(:,:,1)+meansrgI(:,:,2)+meansrgI(:,:,3));
    figure;
    subplot(1,2,1)
    imshow(uint8(means))
    subplot(1,2,2)
    imshow(uint8(deviations))
    
    %Define alpha
    %Define rho
    rho=0.2;
    alpha=5;
    
    identification=zeros(1,100);
    counter=ones(1,100);
    velocity=cell(1,100);
    for r=1:100
        velocity{r}=0;
    end
    
    %Get the information of the input and groundtruth images
    FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
    
    %Detect foreground objects in the second half of the sequence
    for i = iniFrame(seq)+25:endFrame(seq)
        
        %Read an image and convert it to grayscale
        image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
        image = imresize(image,0.25);
        grayscale = double(rgb2gray(image));
        
        if i == iniFrame(seq)+25
            previousFrame = grayscale;
        end
        
        [resultImage, motion_i, motion_j] = blockMatching_b(previousFrame, grayscale);
        
        moi = reshape(motion_i, 1, size(motion_i,1)*size(motion_i,2));
        moj = reshape(motion_j, 1, size(motion_j,1)*size(motion_j,2));
        
        mo_i = median(moi);
        mo_j = median(moj);
        
        grayscale = imtranslate(grayscale,[mo_j,mo_i],'FillValues',111);
        previousFrame = grayscale;
        
        
        %Detect foreground objects
        [detection,means,deviations] = detectForeground_adaptive(grayscale, means, deviations,alpha,rho);
        
        %Apply morphology to create blobs of the moving objects
        detection = imfill(detection, 'holes');
        detection = bwareaopen(detection,20);
        SE = strel('disk',5);
        
        detection=imclose(detection,SE);
        detection=imopen(detection,SE);
        detection = medfilt2(detection,[15,15]);
        
        % Shadow Removal
        %detection = detectShadows(image,detection, meansrgI);
        
        %Get an aerial view of the road
        detection_=RemovePerspective(detection,H,[480 270]);
        image_=RemovePerspective(image,H,[480 270]);
        
        detection_=logical(detection_(:,:,1));
        
        %Kalman Filter - tracking
        [area,centroids, bboxes] = step(blobAnalyzer,detection_);
        tracks=predictNewLocationsOfTracks(tracks);
        [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment(tracks,centroids,1);
        
        tracks=updateAssignedTracks(assignments,centroids,bboxes,tracks);
        tracks=updateUnassignedTracks(tracks,unassignedTracks);
        tracks=deleteLostTracks(tracks);
        [nextId,tracks]=createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId);
        
        %Display 2 lines - the speed computation is only done in the middle
        image_(49:51,:,1)=255;
        image_(49:51,:,2)=0;
        image_(49:51,:,3)=0;
        
        image_(424:426,:,1)=255;
        image_(424:426,:,2)=0;
        image_(424:426,:,3)=0;
        
        
        for o=1:length(tracks)
            if identification(tracks(o).id)==0
                firstPixelBbox{tracks(o).id}(1,:)=[tracks(o).bbox(1),tracks(o).bbox(2)];
                identification(tracks(o).id)=1;
            else
                firstPixelBbox{tracks(o).id}=vertcat(firstPixelBbox{tracks(o).id}, [tracks(o).bbox(1),tracks(o).bbox(2)]);
            end
            
            %Define characteristics of the road and video sequence
            pixel_meter=9.0/79.0;
            to_km=3.6;
            wait_frames = 3.0;
            time=wait_frames/30.0;
            
            if length(firstPixelBbox{tracks(o).id})>=wait_frames
                ref=firstPixelBbox{tracks(o).id}(counter(tracks(o).id),1);
                
                %Compute speed
                displacement=sqrt(double((firstPixelBbox{tracks(o).id}(counter(tracks(o).id),1)- firstPixelBbox{tracks(o).id}(counter(tracks(o).id)+wait_frames-1,1))^2 + (firstPixelBbox{tracks(o).id}(counter(tracks(o).id),2)- firstPixelBbox{tracks(o).id}(counter(tracks(o).id)+wait_frames-1,2))^2)) ;
                velocity{tracks(o).id}= ((displacement*pixel_meter)/time)*to_km;
                
                %Consider a valid car when we have to calculate velocity
                if  counter(tracks(o).id)==5
                    num_cars=num_cars+1;
                end
                
                counter(tracks(o).id)=counter(tracks(o).id)+1;
                
            end
        end
        
        %Display results
        [speed_limit_pictures,speed_limit_id,speed_limit_labels,speed_limit_num_frame]= displayTrackingResults(i,T,image,image_,detection_,tracks,velocity,speed_limit_pictures,speed_limit_id,speed_limit_labels,speed_limit_num_frame);
        
        if video==1
            F(ind) = getframe(gcf);
            writeVideo(v,F(ind));
            ind=ind+1;
        end
        
    end
    
end

if video==1
    %Close video object
    close(v)
end

disp(['Total number of cars in the road: ' int2str(num_cars)])

figure;
for i=1:numel(speed_limit_num_frame)
    image = imread(strcat(char(sequencePath(seq)),FilesInput(speed_limit_num_frame(i)).name));
    bb=speed_limit_pictures{i};
    bb=bb{1};
    lab=speed_limit_labels{i};
    subplot(1,numel(speed_limit_num_frame),i)
    imshow(image(4*bb(2):4*bb(2)+4*bb(4), 4*bb(1):4*bb(1)+4*bb(3),:));
    title(cellstr(lab))
end
toc
