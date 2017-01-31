%Highway 1050 - 1350
%Fall 1460 - 1560
%Traffic 950 - 1050
close all
clear all

video=1;
tic
%Paths to the input images and their groundtruth
sequencePath = {'../Our video/'} ;
%groundtruthPath = {'../Archivos/traffic/traffic/groundtruth/'};

%Initial and final frame of the sequence
iniFrame = 1;
endFrame = 191;


seq=1;


%Get the information of the input and groundtruth images
FilesInput = dir(char(strcat(sequencePath(seq), '*jpg')));
%FilesGroundtruth = dir(char(strcat(groundtruthPath(seq), '*png')));

if video==1 
    NFrames=length(FilesInput);
    figure();
    set(gcf, 'Position', get(0,'Screensize')); % Maximize figure
    F(NFrames) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('Traffic-task2_2.avi');
    v.FrameRate = 30;
    open(v)
end

k=0;
%Detect foreground objects in the second half of the sequence
for i = iniFrame(seq):endFrame(seq)
    %Read an image and convert it to grayscale
    image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
    grayscale = double(rgb2gray(image));
    if i == iniFrame(seq)
        previousFrame = grayscale;
    end
    i
    [resultImage, motion_i, motion_j] = blockMatching_b(previousFrame, grayscale);
    %display('""""""""""""""""""')
    mo_i = median(median(motion_i(~isnan(motion_i))));
    mo_j = median(median(motion_j(~isnan(motion_j))));
    
    trans = imtranslate(image,[mo_j,mo_i]);
    %trans=image;
    figure(1)
    %subplot(1,2,1)
    %imshow(uint8(grayscale));
    %subplot(1,2,2)
    imshow((trans));
    
    %hold on
    %comp_of=opticalFlow(-motion_i,-motion_j);     
    %plot(comp_of,'DecimationFactor',[1 1], 'ScaleFactor',1)
    %hold off
    drawnow()
    if video == 1
        F(i) = getframe(gcf);
        writeVideo(v,F(i));
    end
    previousFrame = double(rgb2gray(trans));
    %Show the output of the detector
    %figure(2)
    %imshow(detection)
    
end

if video==1
    %Close video object
    close(v)
end

toc