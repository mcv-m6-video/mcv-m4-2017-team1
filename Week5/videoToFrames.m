v = VideoReader('03_twolanes_jitter.MOV');
i=0;
while hasFrame(v)
    ii = sprintf('%06d', i);
    frame = readFrame(v);
    imshow(frame);
    imwrite(frame, strcat('datasets/ronda/03_twolanes_jitter/', ii, '.jpg'))
    i = i+1;
end