    function [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment_MS(tracks,bboxes)

        nTracks = length(tracks);
        nDetections = size(bboxes, 1);
        
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            G  = tracks(i).bbox;
            G2 = bboxes;
            
            for numberOfBBoxes = 1 : size(bboxes,1)
                acum = 0;
                for indexPositions = 1 : size(bboxes,2)
                    acum = sqrt(sum((G(indexPositions) - G2(numberOfBBoxes,indexPositions)) .^ 2));
                end
                cost(i, numberOfBBoxes) = acum;
            end
            
            %cost(i, :) = distance(tracks(i).MeanShift, centroids);
        end
        
        costOfNonAssignment = 20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end