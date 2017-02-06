function [speed_limit_pictures,speed_limit_id,speed_limit_labels]=displayTrackingResults(frame,mask,tracks,velocity,speed_limit_pictures,speed_limit_id,speed_limit_labels)
% Convert the frame and the mask to uint8 RGB.
frame = im2uint8(frame);
mask = uint8(repmat(mask, [1, 1, 3])) .* 255;

minVisibleCount = 4;
if ~isempty(tracks)
    
    % Noisy detections tend to result in short-lived tracks.
    % Only display tracks that have been visible for more than
    % a minimum number of frames.
    reliableTrackInds = ...
        [tracks(:).totalVisibleCount] > minVisibleCount;
    reliableTracks = tracks(reliableTrackInds);
    
    % Display the objects. If an object has not been detected
    % in this frame, display its predicted bounding box.
    if ~isempty(reliableTracks)
        % Get bounding boxes.
        bboxes = cat(1, reliableTracks.bbox);
        
        % Get ids.
        ids = int32([reliableTracks(:).id]);
        
        % Create labels for objects indicating the ones for
        % which we display the predicted rather than the actual
        % location.
        labels = cellstr(int2str(ids'));
        velocity1=cell2mat(velocity);
        predictedTrackInds = ...
            [reliableTracks(:).consecutiveInvisibleCount] > 0;
        isPredicted = cell(size(labels));
        isPredicted(predictedTrackInds) = {' predicted'};
        labelsextra=cell(size(labels));
        color={};
        for k=1:length(ids)
            labelsextra(k)= { ' speed= '};
        end
        
        if isempty(velocity)
            labels = strcat(labels, isPredicted);
            
        else
            vel=cellstr(int2str(velocity1(ids)'));
            labels = strcat(labels, labelsextra ,vel, isPredicted);
            v=velocity1(ids);
            for k=1:length(v)

                if v(k)>50
                    if isempty(color)
                        color{1}='red';
                     else
                        color{end+1}='red';
                    end
                else
                    if isempty(color)
                        color{1}='yellow';
                    else
                        color{end+1}='yellow';
                    end
                end
            end
        end
        
        %Eliminate predicted velocities and bounding boxes
        disp('new iteration')
        
        bb_s=size(bboxes);
        lab_size=size(labels);
        vec_ind=[];
        bboxes_=[];
        labels_={};
        color_={};
        for ind=1:lab_size(1)
            k = findstr(labels{ind}, 'predicted');
            if ~isempty(k)
                vec_ind=[vec_ind ind];
            end
        end
        new_ind=1;
        for i=1:bb_s(1)
            if (sum(i==vec_ind)==0)
                bboxes_(new_ind,:)=bboxes(i,:);
                labels_{new_ind}=labels{i};
                color_{new_ind}=color{i};
                new_ind=new_ind+1;
            end
        end
        % if ~isempty(labels) && numel(labels)>1
        %labels(cellfun('isempty',labels)) = [];
        % color(cellfun('isempty',color)) = [];
        %end
        % Draw the objects on the frame.
        if ~isempty(bboxes_) && ~isempty(labels_)
            frame = insertObjectAnnotation(frame, 'rectangle', ...
                bboxes_, labels_,'Color',color_);
            % Draw the objects on the mask.
            mask = insertObjectAnnotation(mask, 'rectangle', ...
                bboxes_, labels_,'Color',color_);
            
            %% Density control
            if numel(labels_)>=4
                color_density='red';
                text_density='High density';
            elseif numel(labels_)>2 && numel(labels_)<4
                color_density='yellow';
                text_density='Moderate density';
            elseif numel(labels_)<=2
                color_density='green';
                text_density='Low density';
            end
            
            mask = insertText(mask,[0 0],text_density,'FontSize',18,'BoxColor',...
                color_density,'BoxOpacity',0.4,'TextColor','white');
            frame = insertText(frame,[0 0],text_density,'FontSize',18,'BoxColor',...
                color_density,'BoxOpacity',0.4,'TextColor','white');
            %% Save image of cars which surpassed speed limit
            
            for i=1:numel(labels_)
                if strcmp(color_{i},'red')
                    if sum(str2num(labels_{i}(1))==speed_limit_id)==0
                        i
                        labels_
                        bboxes_
                    aux=bboxes_(i,:);
                    %speed_limit_pictures={speed_limit_pictures; frame(aux(1):aux(1)+aux(3),aux(2):aux(2)+aux(4))};
                    speed_limit_pictures(end+1)={frame(aux(1):aux(1)+aux(3),aux(2):aux(2)+aux(4))};
                    speed_limit_labels=[speed_limit_labels; labels_{i}];
                    speed_limit_id=[speed_limit_id; str2num(labels_{i}(1))];
                end
            end
            
            end
        else
               mask = insertText(mask,[0 0],'Low density','FontSize',18,'BoxColor',...
                'green','BoxOpacity',0.4,'TextColor','white');
             frame = insertText(frame,[0 0],'Low density','FontSize',18,'BoxColor',...
                'green','BoxOpacity',0.4,'TextColor','white');
         
        end

end

% Display the mask and the frame.
subplot(1,2,1)
imshow(frame)
subplot(1,2,2)
imshow(mask)
drawnow()
end