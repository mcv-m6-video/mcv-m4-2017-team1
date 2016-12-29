clc;
close all;

%Directories of original images, Test and ground truth
InputDirectory = 'datasets/highway/reduced_input/';
%TestDirectory = '../results/highway/testA/';
%GTDirectory = '../datasets/highway/reducedGT/';

video = 0; %Decide to save a video with the background substraction result

%Store the information from the directories (#images, names...)
FilesInput = dir(strcat(InputDirectory, '*jpg'))
%FilesTest = dir(strcat(TestDirectory, '*png'));
%FilesGT = dir(strcat(GTDirectory, '*png'));

%Get sequence lenght
NFrames = length(FilesInput)
%Initialize variables
%FMeasure = zeros(1,NFrames);
%TP = zeros(1,NFrames);
%FG = zeros(1,NFrames);

%Create a videowriter
if video==1
    F(NFrames) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('FMeasure.avi');
    v.FrameRate = 10;
    open(v)
end
pixelMean=[];
pixelStd=[];
all_frames=zeros(240,320,NFrames);
figure;

for i = 1:NFrames
    
    %Read input image
    realImage = rgb2gray(imread(strcat(InputDirectory, FilesInput(i).name)));
    all_frames(:,:,i)=realImage;
    imshow(realImage);
    %Only show one of the plots as they are updated in real time
    if video==0
        %Plot results
   %     figure(1)
   %     ax1 = subplot(1,2,1);
%        plot(1:i,TP(1:i),1:i,FG(1:i)); axis([0 200 0 12000]); 
 %       xlabel(ax1,'#frame'); ylabel(ax1,'Number of pixels'); 
  %      drawnow();

    %    ax2 = subplot(1,2,2);
     %   plot(1:i,FMeasure(1:i)); axis([0 200 0 1]); 
      %  xlabel(ax2,'#frame'); ylabel(ax2,'F Measure'); drawnow();
    elseif video==1
        %Plot the input image, test image and F Measure
        figure(3)  
        subplot(2,2,1); imshow(realImage); title('Input image')
        subplot(2,2,2); imshow(testImage); title('Result from Test')
        subplot(2,2,[3,4]); plot(1:i,FMeasure(1:i),'b'); title('F Measure');
        xlabel('# frame'); ylabel('F Measure')
        axis([0 200 0 1])
        drawnow(); 
        %Save the figure in a video
        F(i) = getframe(gcf);
        writeVideo(v,F(i));
    end

end
pixelMean=mean(all_frames,3);
pixelStd=std(all_frames,0,3);
figure;
imshow(uint8(pixelMean));
figure;
imshow(uint8(pixelStd));

if video==1
    %Close video object
    close(v)
elseif video==0
    %Add legend of ax1
  %  legend(ax1,'True positives','Positives');
end

