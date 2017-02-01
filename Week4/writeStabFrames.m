filename = 'trafficStabilized_input.avi';
hVideoSource = vision.VideoFileReader(filename, ...
                              'ImageColorSpace', 'Intensity',...
                              'VideoOutputDataType', 'double');
filenameGT = 'trafficStabilizedGT.avi';
hVideoSourceGT = vision.VideoFileReader(filenameGT, ...
                              'ImageColorSpace', 'Intensity',...
                              'VideoOutputDataType', 'double');

inputPath = 'datasets/trafficStab/input/';
gtPath = 'datasets/trafficStab/groundtruth/';

i=0;
while ~isDone(hVideoSource)
    input = step(hVideoSource);
    gt = step(hVideoSourceGT);
    
    
    input_name = strcat(inputPath,sprintf('in%04d',i),'.jpg');
    gt_name = strcat(gtPath,sprintf('gt%04d',i),'.png');
    i=i+1;
    
    imwrite(input, input_name);
    imwrite(gt, gt_name);
end
                                  