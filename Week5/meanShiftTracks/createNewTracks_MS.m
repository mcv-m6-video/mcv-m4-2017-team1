function [nextId,tracks]=createNewTracks_MS(tracks,unassignedDetections,bboxes,nextId, image_)

bboxes = bboxes(unassignedDetections, :);

for i = 1:size(bboxes, 1)
    
    bbox = bboxes(i, :);
    
    tracker = vision.HistogramBasedTracker;

    % Initialize the tracker histogram 
    initializeObject(tracker, double(rgb2gray(image_)), bbox);
     
    % Create a new track.
    newTrack = struct(...
        'id', nextId, ...
        'bbox', bbox, ...
        'MS_tracker', tracker, ...
        'age', 1, ...
        'totalVisibleCount', 1, ...
        'consecutiveInvisibleCount', 0, ...
        'score',1 ...
        );
    
    % Add it to the array of tracks.
    tracks(end + 1) = newTrack;
    
    % Increment the next id.
    nextId = nextId + 1;
end
end