%Highway 1050 - 1350
%Fall 1460 - 1560
%Traffic 950 - 1050
close all
clear all

video=1;
tic
%Paths to the input images and their groundtruth
sequencePath = {'datasets/traffic/input/'} ;
groundtruthPath = {'datasets/traffic/groundtruth/'};

%Initial and final frame of the sequence
iniFrame = 950;
endFrame = 1050;


seq=1;


%Get the information of the input and groundtruth images
FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
FilesGroundtruth = dir(char(strcat(groundtruthPath(seq), '*png')));

if video==1 
    NFrames=length(FilesInput);
    figure();
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
    F(NFrames) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('Traffic-task2_2.avi');
    v.FrameRate = 10;
    open(v)
end


%Detect foreground objects in the second half of the sequence
for i = iniFrame(seq):endFrame(seq)
    %Read an image and convert it to grayscale
    image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
    grayscale = double(rgb2gray(image));
    if i == iniFrame(seq)
        previousFrame = grayscale;
    end

    [resultImage, motion_i, motion_j] = blockMatching_b(previousFrame, grayscale);
    %display('""""""""""""""""""')
    
    moi = reshape(motion_i, 1, size(motion_i,1)*size(motion_i,2));
    moj = reshape(motion_j, 1, size(motion_j,1)*size(motion_j,2));

    mo_i = median(moi);
    mo_j = median(moj);
    
    %mo_i = mean2(motion_i(~isnan(motion_i)));
    %mo_j = mean2(motion_j(~isnan(motion_j)));
    
    trans = imtranslate(grayscale,[mo_j,mo_i]);
    figure(1)
    %subplot(1,2,1)
    %imshow(uint8(grayscale));
    %subplot(1,2,2)
    imshow(uint8(trans));
    
    %hold on
    %comp_of=opticalFlow(-motion_i,-motion_j);     
    %plot(comp_of,'DecimationFactor',[1 1], 'ScaleFactor',1)
    %hold off
    drawnow()
    if video == 1
        F(i) = getframe(gcf);
        writeVideo(v,F(i));
    end
    previousFrame = trans;
    %Show the output of the detector
    %figure(2)
    %imshow(detection)
    
end

if video==1
    %Close video object
    close(v)
end

toc