%Highway 1050 - 1350
%Fall 1460 - 1560
%Traffic 950 - 1050
%close all
clear all

video=1;
tic
%Paths to the input images and their groundtruth
sequencePath = {'../Archivos/highway/input/' '../Archivos/traffic/traffic/input/'} ;
groundtruthPath = {'../Archivos/highway/groundtruth/' '../Archivos/traffic/traffic/groundtruth/'};
%Initial and final frame of the sequence
iniFrame = [1050 950];
endFrame = [1350 1050];
for seq=1
    disp(['Sequence ' num2str(seq)])
    
    % Create System objects used for detecting moving objects
    blobAnalyzer = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', true, 'CentroidOutputPort', true, ...
        'MinimumBlobArea',70);
    figure;
    if seq==1
        x1=[212 1; 1 240; 268 240; 280 1];
        x1 = makehomogeneous(x1');
        x2 = [0 0; 0 240; 212 240; 212 0];
        x2 = makehomogeneous(x2');
% x2 = [0 0 1; 0 1, 1; 1, 1, 1; 1, 0, 1];

        H = homography2d(x1, x2);
    end
    tracks = initializeTracks(); % Create an empty array of tracks.
    
    nextId = 1; % ID of the next track
    num_cars=0;
    
    %Train the background model with the first half of the sequence
    [means, deviations] = trainBackgroundModelAllPix(char(sequencePath(seq)), char(groundtruthPath(seq)), iniFrame(seq), (endFrame(seq)-iniFrame(seq))/2);
    na_means=means;
    na_deviations=deviations;
    
    %Get the information of the input and groundtruth images
    FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
    % FilesGroundtruth = dir(char(strcat(groundtruthPath(seq), '*png')));
    
    
    %Chose type of SE
    %SE = strel('line',20,30);  %len es llargada i deg els graus
    SE = strel('disk',10);
    conn=4; %connectivity
    if seq==1
        al=2;
        rho=0.22;
    else
        al=4;
        rho=0.22;
    end
    deviations=na_deviations;
    means=na_means;
    iter=1;
    k=1;
    identification=zeros(1,100);
    counter=ones(1,100);
    velocity=cell(1,100);
    for r=1:100
        velocity{r}=0;
    end
    
    if video==1 
    NFrames=length(FilesInput);
    figure();
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
    F(NFrames) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('TrafficTracking.avi');
    v.FrameRate = 10;
    open(v)
    end
    
    
    
    
    
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
%         if seq==1            
%             %homography
%             detection_=RemovePerspective(detection,H,[240 212]);
%             imagenext_=RemovePerspective(imagenext,H,[240 212]);
%        
%             detection_=logical(detection_(:,:,1)); 
%         else
%             detection_=detection;
%             imagenext_=imagenext;
%         end
        
        %Kalman Filter
        [area,centroids, bboxes] = step(blobAnalyzer,detection);
        tracks=predictNewLocationsOfTracks(tracks);
        [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(tracks,centroids,seq);
        
        tracks=updateAssignedTracks(assignments,centroids,bboxes,tracks);
        tracks=updateUnassignedTracks(tracks,unassignedTracks);
        tracks=deleteLostTracks(tracks);
        [nextId,tracks]=createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId);
            
        for o=1:length(tracks)
            if identification(tracks(o).id)==0
                centroidsVel{tracks(o).id}(k,:)=[tracks(o).bbox(1)+(tracks(o).bbox(3)/2),tracks(o).bbox(2)+(tracks(o).bbox(4)/2), tracks(o).bbox(3)];
                identification(tracks(o).id)=1;
            else
                centroidsVel{tracks(o).id}=vertcat(centroidsVel{tracks(o).id}, [tracks(o).bbox(1)+(tracks(o).bbox(3)/2),tracks(o).bbox(2)+(tracks(o).bbox(4)/2), tracks(o).bbox(3)]);
            end
            time=6/30;
            
            if seq==1
                if centroidsVel{tracks(o).id}(counter(tracks(o).id),2)<32
                    pixel_meter=2;
                elseif centroidsVel{tracks(o).id}(counter(tracks(o).id),2)<64
                    pixel_meter=1;
                elseif centroidsVel{tracks(o).id}(counter(tracks(o).id),2)<96
                    pixel_meter=4.5/12;
                elseif centroidsVel{tracks(o).id}(counter(tracks(o).id),2)<128
                    pixel_meter=4.5/15;
                elseif centroidsVel{tracks(o).id}(counter(tracks(o).id),2)<160
                    pixel_meter=4.5/18;
                elseif centroidsVel{tracks(o).id}(counter(tracks(o).id),2)<192
                    pixel_meter=4.5/22;
                elseif centroidsVel{tracks(o).id}(counter(tracks(o).id),2)>191
                    pixel_meter=4.5/27;   
                end    
            else
                if centroidsVel{tracks(o).id}(counter(tracks(o).id),2)<45
                    pixel_meter=1/5;
                elseif centroidsVel{tracks(o).id}(counter(tracks(o).id),2)<65
                    pixel_meter=1/8;
                elseif centroidsVel{tracks(o).id}(counter(tracks(o).id),2)<100
                    pixel_meter=1/10;   
                else
                    pixel_meter=1/10;
                end
               
            end           
            to_km=3.6;
            
            if length(centroidsVel{tracks(o).id})>5
                displacementall{tracks(o).id}(counter(tracks(o).id))=sqrt(double((centroidsVel{tracks(o).id}(counter(tracks(o).id),1)- centroidsVel{tracks(o).id}(counter(tracks(o).id)+5,1))^2 + (centroidsVel{tracks(o).id}(counter(tracks(o).id),2)- centroidsVel{tracks(o).id}(counter(tracks(o).id)+5,2))^2)) ;

                    
                %displacement{tracks(o).id}=sum(displacementall{tracks(o).id})/length(displacementall{tracks(o).id});               
                displacement{tracks(o).id}=displacementall{tracks(o).id}(counter(tracks(o).id));
                velocityall{tracks(o).id}(counter(tracks(o).id))= ((displacement{tracks(o).id}*pixel_meter)/time)*to_km;
                velocity{tracks(o).id}=sum(velocityall{tracks(o).id})/length(velocityall{tracks(o).id});
               
                %Consider a valid car when we have to calculate velocity
                if  counter(tracks(o).id)==1
                    num_cars=num_cars+1;
                end
                    
                counter(tracks(o).id)=counter(tracks(o).id)+1;
            else
                
            end
        end

        [frame, mask1]= displayTrackingResultsHighway(imagenext,detection,tracks, velocity);
        if video==1
                subplot(1,2,1); imshow(frame);
                title('Sequence Highway')
                subplot(1,2,2); imshow(mask1);
                title('Detection')
        F(i) = getframe(gcf);
        writeVideo(v,F(i));
        end
        end
end
if video==1
    %Close video object
    close(v)
end

disp(['Total number of cars in the road: ' int2str(num_cars)])
