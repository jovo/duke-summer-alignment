function [ features ] = getpeakfeatures( img, ypeak, xpeak ) 
% [ features ] = getpeakfeatures( img ) takes input image img, peak values 
% xpeak, ypeak, and returns a 1 x k vector with values of k features 

sz = size(img,3);
features = NaN(sz,7); 

for i = 1:sz
    c = img(:,:,i); 

%gradient, Laplacian
[Gmag, ~] = imgradient(c);
features(i,1) = Gmag(ypeak,xpeak);
[Lmag, ~] = imgradient(Gmag);
features(i,2) = Lmag(ypeak,xpeak);

%histogram statistics  
features(i,3) = mean(double(c(:)));
features(i,4) = var(double(c(:)));
features(i,5) = skewness(double(c(:))); %negative skew = skewed left 
features(i,6) = kurtosis(double(c(:)));

%counts # pixels within certain range (exp correct = small)
cBinary = roicolor(c,230,255); %lower bound arbitrarily set at 230
[ymax, xmax, value] = find(cBinary);
features(i,7) = size(ymax,1); 

%image edge pixels statistics
left = c(:,1); 
right = c(:,size(img,2)); 
top = c(1,2:size(img,2)-1);
bottom = c(size(img,1),2:size(img,2)-1);
edge = [left;right;top;bottom];
features(i,8) = mean(edge);
features(i,9) = var(edge);
features(i,10) = skewness(edge); 
features(i,11) = kurtosis(edge);

%contour map 
imcontour(c);
%find highest value contour line, within region of x pixels around it,
%are there multiple contour line values??

end

end
