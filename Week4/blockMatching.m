function [resultImage, motion_i, motion_j] = blockMatching(previousFrame, currentFrame)

plot_progress=0;
plot_block_search=1;

% Save the original images, needed for the plots and resultImage
previousFrame_rgb = previousFrame;
currentFrame_rgb = currentFrame;
% Convert both frames to double (and gray)
previousFrame = rgb2gray(previousFrame);
currentFrame = rgb2gray(currentFrame);
previousFrame = double(previousFrame);
currentFrame = double(currentFrame);

% %% Fast to see algorithm: [40,40], 10
% %% ~Good performance (not optimal): [20,20] 20
% Define block size
blockSize = [40,40];
% Define the area of search (lenSearch pixels beyond each of the limits of
% the block)
lenSearch = 10;

%Matrices to store the movement in the i and j direction of each block
%(motion vectors)
motion_i = zeros(size(currentFrame));
motion_j = zeros(size(currentFrame));

%Resulting image, created with the matching blocks of the previous frame 
resultImage = zeros(size(currentFrame_rgb));

%% Backward block matching
if plot_block_search==1
   figure(1)
   subplot(2,2,1); imshow(uint8(previousFrame_rgb)); title('Previous Frame');
   subplot(2,2,2); imshow(uint8(currentFrame_rgb)); title('Current Frame');
   subplot(2,2,3:4); imshow(uint8(resultImage)); title('Result image');
   drawnow()
   rect_blue_0=[];
   rect_blue=[];
   rect_blue2=[];
   rect_red=[];
end
% For each block in the current frame:
for i = 1:blockSize(1):size(currentFrame,1)
    
    for j = 1:blockSize(2):size(currentFrame,2)
        if plot_block_search==1
            figure(1); subplot(2,2,1);
            delete(rect_blue_0)
            rect_blue_0 = rectangle('Position',[j,i, blockSize(2),blockSize(1)],'EdgeColor', 'b');
            figure(1); subplot(2,2,2);
            delete(rect_blue)
            rect_blue = rectangle('Position',[j,i, blockSize(2),blockSize(1)],'EdgeColor', 'b');
            figure(1); subplot(2,2,3:4);
            delete(rect_blue2)
            rect_blue2 = rectangle('Position',[j,i, blockSize(2),blockSize(1)],'EdgeColor', 'b'); 
            drawnow()
        end
        
        % Initialize the minimum error
        minError = 1000000000;
        
        %Avoid iterations where an index goes out of the border of
        %the image
        if ( ( (i+blockSize(1)-1) > size(currentFrame,1)) || ...
           ( (j+blockSize(2)-1) > size(currentFrame,2)))
            continue
        end
                
        % Save the current block in a variable
        currentBlock = currentFrame(i:i+blockSize(1)-1,...
                                              j:j+blockSize(2)-1);  
                                          
        % In the previous frame, move a block around the (i,j) position,
        % lenSearch pixels in each direction
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
                
                if plot_block_search==1
                    figure(1); subplot(2,2,1);
                    delete(rect_red)
                    rect_red = rectangle('Position',[j+stepj,i+stepi, blockSize(2),blockSize(1)],'EdgeColor', 'r');
                    drawnow()
                end
                
                % Save the previous block in a variable
                previousBlock = previousFrame(i+stepi:i+stepi+blockSize(1)-1,...
                                              j+stepj:j+stepj+blockSize(2)-1);
                                       
                % Compute the error between the two blocks                          
                e = computeError(previousBlock,currentBlock);
                
                if plot_progress == 1
                    figure(2)
                    subplot(2,2,1)
                    imshow(uint8(currentBlock))
                    subplot(2,2,2)
                    imshow(uint8(previousBlock))
                    drawnow()
                end
                
                % If the error is smaller than the minumum one ( = most 
                % similar block), save it
                if e < minError
                    % Save the minimum error
                    minError = e;
    
                    % Save the motion of the most 
                    motion_i(i:i+blockSize(1)-1,j:j+blockSize(2)-1) = stepi;
                    motion_j(i:i+blockSize(1)-1,j:j+blockSize(2)-1) = stepj;
                    
                    % Put the most similar block in the resulting image
                    previousBlock_rgb = previousFrame_rgb(i+stepi:i+stepi+blockSize(1)-1,...
                                              j+stepj:j+stepj+blockSize(2)-1,:);
                                                                   
                    resultImage(i:i+blockSize(1)-1, j:j+blockSize(2)-1,:) = previousBlock_rgb;
                    
                    if plot_block_search == 1
                        figure(1)
                        subplot(2,2,3:4); imshow(uint8(resultImage)); title('Result image');
                        drawnow()
                    end
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