function [improved_detection] = detectShadows(frame, detection, bg_rgI)

rgI = double(frame);
rgI(:,:,1) = rgI(:,:,1)./(rgI(:,:,1)+rgI(:,:,2)+rgI(:,:,3));
rgI(:,:,2) = rgI(:,:,2)./(rgI(:,:,1)+rgI(:,:,2)+rgI(:,:,3));
rgI(:,:,3) = (rgI(:,:,1)+rgI(:,:,2)+rgI(:,:,3));



shadow_detection = ((rgI(:,:,1)./bg_rgI(:,:,1)) > 0.8 & (rgI(:,:,1)./bg_rgI(:,:,1)) < 1.2) .* ...
    ((rgI(:,:,2)./bg_rgI(:,:,2)) > 0.8 & (rgI(:,:,1)./bg_rgI(:,:,2)) < 1.2) .* ...
    ((rgI(:,:,3) ./ bg_rgI(:,:,3)) < 0.2);

improved_detection = detection.*~shadow_detection;

end