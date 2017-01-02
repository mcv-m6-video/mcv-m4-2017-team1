function newStdDev = add2StdDev(mean, stdDev, newValue, newMean, newN,mask)

%Compute the deviation when adding a new element
newStdDev = sqrt( ((newN-2).*stdDev.^2 + (newValue-newMean).*(newValue-mean)) ./ (newN-1) );

%Put to 0 those values that are Inf or NaN (if the deviation is divided by
%0 or is 0/0)
newStdDev(isinf(newStdDev)) = 0;
newStdDev(isnan(newStdDev)) = 0;

%Set the new deviation only on those pixels that are background
newStdDev = newStdDev.*mask + stdDev.*~mask;

end