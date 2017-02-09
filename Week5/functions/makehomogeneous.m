function hx = makehomogeneous(x)
 % Function used from Team2, class2016 , M4   
    [rows, npts] = size(x);
    hx = ones(rows+1, npts);
    hx(1:rows,:) = x;