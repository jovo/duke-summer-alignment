function [ features ] = getpeakfeatures( img, ypeak, xpeak ) 
% [ features ] = getpeakfeatures( img ) takes input image img, peak values 
% xpeak, ypeak, and returns a 1 x k vector with values of k features 

% define sizes
sizeyimg = size(img,1);
sizeximg = size(img,2);
cropsy = floor(sizeyimg/20);
cropsx = floor(sizeximg/20);
features = NaN(1,9);

% normalize to between 0 and 255.
img = img-min(img(:));  % minimum = 0
img = img.*(255/max(img(:)));    % range from 0 to 255

% padarray and crop
img = padarray(img, [cropsy, cropsx], 'symmetric');
yp = ypeak+cropsy;
xp = xpeak+cropsy;
c = img(yp-cropsy:yp+cropsy, xp-cropsx:xp+cropsx);
ypeakcrop = 1+cropsy;
xpeakcrop = 1+cropsx;
sizeycrop = size(c,1);
sizexcrop = size(c,2);

% figure; imshow(c, [min(c(:)),max(c(:))]);
% hold on
% plot(xpeakcrop, ypeakcrop, 'ro');
% hold off

% gradient, Laplacian
[Gmag, ~] = imgradient(c);
features(1) = Gmag(ypeakcrop,xpeakcrop);
[Lmag, ~] = imgradient(Gmag);
features(2) = Lmag(ypeakcrop,xpeakcrop);

% histogram statistics
features(3) = mean(double(c(:)));
features(4) = var(double(c(:)));
features(5) = skewness(double(c(:))); % negative skew = skewed left
features(6) = kurtosis(double(c(:)));

% counts # pixels within certain range (exp correct = small)
cBinary = roicolor(c,230,255); % lower bound arbitrarily set at 230
[ymax, ~, ~] = find(cBinary);
features(7) = size(ymax,1);

% image edge pixels statistics
left = c(:,1);
right = c(:,sizexcrop);
top = c(1,2:sizexcrop-1)';
bottom = c(sizeycrop,2:sizexcrop-1)';
edge = [left;right;top;bottom];
features(8) = mean(edge);
features(9) = var(edge);

% contour map
% imcontour(c);
% find highest value contour line, within region of x pixels around it,
% are there multiple contour line values??

end
