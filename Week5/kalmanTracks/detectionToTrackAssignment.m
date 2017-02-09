    function [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(tracks,centroids,sequence)
%Function extracted and modified from Matlab's source code
        nTracks = length(tracks);
        nDetections = size(centroids, 1);

        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end

        % Solve the assignment problem.

        if sequence==1
            costOfNonAssignment = 12.25;
        else
            costOfNonAssignment = 12.2065;
        end
        
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end