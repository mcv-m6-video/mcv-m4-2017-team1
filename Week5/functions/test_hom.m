%x = [82; 153; 4; 261];
%y = [103; 87; 291; 305];


%x1 = [x, y];
x1=[80 126; 161 127; 18 309; 480 270];
x1 = makehomogeneous(x1');
x2 = [0 0; 270 0; 0 480; 480 270];
x2 = makehomogeneous(x2');
% x2 = [0 0 1; 0 1, 1; 1, 1, 1; 1, 0, 1];

H = homography2d(x1, x2);

%    A = transpose(H)  %Your matrix in here
%    t = maketform('projective',A);
%    y = imtransform(imagenext,t);

y=RemovePerspective(imagenext,H,[480 270]);

figure;
imshow(y)


% 82 103   -- 0 0  -- upper left 

% 153 87  -- 270 0  -- upper right
% 4 291 --  0  480 -- bottom left
% 261 305  -- 480 270 --bottom right
