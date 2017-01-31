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
    v.FrameRate = 10;
    open(v)
end
image1 = imread(strcat(char(sequencePath(seq)),FilesInput(1).name));

hTM = vision.TemplateMatcher('ROIInputPort', true, ...
                            'BestMatchNeighborhoodOutputPort', true);
k=0;
pos.template_orig = [109 100]; % [x y] upper left corner
pos.template_size = [22 18];   % [width height]
pos.search_border = [15 10];   % max horizontal and vertical displacement
pos.template_center = floor((pos.template_size-1)/2);
pos.template_center_pos = (pos.template_orig + pos.template_center - 1);
W = size(image1,2); % Width in pixels
H = size(image1,1); % Height in pixels
BorderCols = [1:pos.search_border(1)+4 W-pos.search_border(1)+4:W];
BorderRows = [1:pos.search_border(2)+4 H-pos.search_border(2)+4:H];
TargetRowIndices = ...
  pos.template_orig(2)-1:pos.template_orig(2)+pos.template_size(2)-2;
TargetColIndices = ...
  pos.template_orig(1)-1:pos.template_orig(1)+pos.template_size(1)-2;
SearchRegion = pos.template_orig - pos.search_border - 1;
Offset = [0 0];
Target = zeros(18,22);
firstTime = true;
sz=size(image);

%Detect foreground objects in the second half of the sequence
for i = iniFrame(seq):endFrame(seq)
    %Read an image and convert it to grayscale
    image = imread(strcat(char(sequencePath(seq)),FilesInput(i).name));
    input = double(rgb2gray(image));
    if i == iniFrame(seq)
        previousFrame = input;
    end
      % Find location of Target in the input video frame
      
    if firstTime
      Idx = int32(pos.template_center_pos);
      MotionVector = [0 0];
      firstTime = false;
    else
      IdxPrev = Idx;

      ROI = [SearchRegion, pos.template_size+2*pos.search_border];
      Idx = step(hTM, input, double(Target), ROI);

      MotionVector = double(Idx-IdxPrev);
    end
    
    [Offset, SearchRegion] = updatesearch(sz, MotionVector, ...
        SearchRegion, Offset, pos);
    
    % Translate video frame to offset the camera motion
    Stabilized = imtranslate(image, Offset, 'linear');

    Target = Stabilized(TargetRowIndices, TargetColIndices);
    
    % Add black border for display
    Stabilized(:, BorderCols) = 0;
    Stabilized(BorderRows, :) = 0;
    
    TargetRect = [pos.template_orig-Offset, pos.template_size];
    SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];
    
    % Draw rectangles on input to show target and search region
    image1 = insertShape(image, 'Rectangle', [TargetRect; SearchRegionRect],...
                        'Color', 'white');
    % Display the offset (displacement) values on the input image
    txt = sprintf('(%+05.1f,%+05.1f)', Offset);
    image1 = insertText(image1(:,:,1),[191 215],txt,'FontSize',12, ...
                    'TextColor', 'white', 'BoxOpacity', 0);

    k=k+1
    figure(1), hold on
    imshow([Stabilized,image1])
    hold off
    drawnow()
    if video == 1
        F(i) = getframe(gcf);
        writeVideo(v,F(i));
    end

end

if video==1
    %Close video object
    close(v)
end

toc