function [nextId,tracks]=createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId)
centroids = centroids(unassignedDetections, :);
bboxes = bboxes(unassignedDetections, :);

for i = 1:size(centroids, 1)
    
    centroid = centroids(i,:);
    bbox = bboxes(i, :);
    
    % Create a Kalman filter object.
    kalmanFilter = configureKalmanFilter('ConstantAcceleration', ...
        centroid, [1 1 1]*1e5,[25, 10, 10], 25);
     
    % Create a new track.
    disp('New track!')
    newTrack = struct(...
        'id', nextId, ...
        'bbox', bbox, ...
        'kalmanFilter', kalmanFilter, ...
        'age', 1, ...
        'totalVisibleCount', 1, ...
        'consecutiveInvisibleCount', 0);
    
    % Add it to the array of tracks.
    tracks(end + 1) = newTrack;
    
    % Increment the next id.
    nextId = nextId + 1;
end
end