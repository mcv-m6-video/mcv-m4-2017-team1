function [resultImage, motion_i, motion_j] = blockMatching(previousFrame, currentFrame)

plot_progress=0;

previousFrame = double(previousFrame);
currentFrame = double(currentFrame);

blockSize = [20,20];
lenSearch = 20;

%Matrices to store the movement in the i and j direction of each block
motion_i = zeros(size(currentFrame));
motion_j = zeros(size(currentFrame));

%Resulting image, created with the matching blocks of the previous frame 
resultImage = zeros(size(currentFrame));


for i = 1:blockSize(1):size(currentFrame,1)
    
    for j = 1:blockSize(2):size(currentFrame,2)
        
        minEnergy = 1000000000;
        
        for stepi = -lenSearch:lenSearch
            for stepj = -lenSearch:lenSearch
                %Avoid iterations where an index goes out of the border of
                %the image
                if ((i+stepi) < 1 || ...
                   (j+stepj) < 1 || ...
                   ( (i+stepi+blockSize(1)-1) > size(currentFrame,1)) || ...
                   ( (j+stepj+blockSize(2)-1) > size(currentFrame,2)) || ...
                   ( (i+blockSize(1)-1) > size(currentFrame,1)) || ...
                   ( (j+blockSize(2)-1) > size(currentFrame,2)))
                    continue
                end

                previousBlock = previousFrame(i+stepi:i+stepi+blockSize(1)-1,...
                                              j+stepj:j+stepj+blockSize(2)-1);
                currentBlock = currentFrame(i:i+blockSize(1)-1,...
                                              j:j+blockSize(2)-1);                         
                                          
                e = computeEnergy(previousBlock,currentBlock);
                
                if plot_progress == 1
                    figure(1)
                    subplot(2,2,1)
                    imshow(uint8(currentBlock))
                    subplot(2,2,2)
                    imshow(uint8(previousBlock))
                    drawnow()
                end
                
                if e < minEnergy
                    minEnergy = e;
                    motion_i(i,j) = stepi;
                    motion_j(i,j) = stepj;
                    resultImage(i:i+blockSize(1)-1, j:j+blockSize(2)-1) = previousBlock;
                    
                    if plot_progress == 1
                        subplot(2,2,3)
                        imshow(uint8(previousBlock))
                        subplot(2,2,4)
                        imshow(uint8(resultImage))
                        drawnow()
                    end
                end

                
            end
        end
        
    end
end