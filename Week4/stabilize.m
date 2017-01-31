function [stabilized_frame] = stabilize(previousFrame, currentFrame)

[resultImage, motion_i, motion_j] = blockMatching(previousFrame, currentFrame);

comp_of=opticalFlow(motion_i,motion_j);
plot(comp_of,'DecimationFactor',[1 1], 'ScaleFactor',1)
stabilized_frame=[]

end
