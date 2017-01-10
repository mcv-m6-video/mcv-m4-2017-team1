function image = ConvertRGBtoYUV (RGB)
R = RGB(:,:,1); 
G = RGB(:,:,2); 
B = RGB(:,:,3); 
Y = 0.299 * R + 0.587 * G + 0.114 * B; 
U = -0.14713 * R - 0.28886 * G + 0.436 * B; 
V = 0.615 * R - 0.51499 * G - 0.10001 * B; 
image = cat(3,Y,U,V); 
end