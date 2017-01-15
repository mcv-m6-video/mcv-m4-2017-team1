function gt = readGroundtruth(name)

gt = double(imread(name));
gt(gt==50) = 0;
gt(gt==255) = 1;
        
end