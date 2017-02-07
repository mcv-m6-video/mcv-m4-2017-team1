 function tracks=predictNewLocationsOfTracks_MS(tracks, image_)
        for i = 1:length(tracks)

            % Predict the current location of the track.
            [bbox, ~, score] = step(tracks(i).MS_tracker, double(rgb2gray(image_)));

            % Shift the bounding box so that its center is at
            % the predicted location.
            tracks(i).bbox = bbox;
            tracks(i).score = score;
        end
    end