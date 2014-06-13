function [ features ] = getpeakfeatures( img, ypeak, xpeak ) 
% [ features ] = getpeakfeatures( img ) takes input image img, peak values 
% xpeak, ypeak, and returns a 1 x k vector with values of k features 

% define sizes
sizeyimg = size(img,1);
sizeximg = size(img,2);
cropsy = floor(sizeyimg/30);
cropsx = floor(sizeximg/30);
features = NaN(1,6);

% get binary image
imgbw = im2bw(img, max(img(:))*0.5);
rp = regionprops(imgbw);
cc = bwconncomp(imgbw);

features(1) = sizeyimg*sizeximg;
features(2) = rp.Area;
features(3) = cc.NumObjects;

% normalize to between 0 and 255 and convert to uint8
img = img-min(img(:));  % minimum = 0
img = uint8(img.*(255/max(img(:))));    % range from 0 to 255

% padarray and crop
img = padarray(img, [cropsy, cropsx], 'symmetric');
yp = ypeak+cropsy;
xp = xpeak+cropsx;
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
features(4) = max(max(Gmag));
[Lmag, ~] = imgradient(Gmag);
features(5) = max(max(Lmag));

% statistics
features(6) = skewness(double(c(:)));

% figure; imshow(Gmag, [min(Gmag(:)),max(Gmag(:))]);
% hold on
% plot(xpeakcrop, ypeakcrop, 'ro');
% hold off
% figure; imshow(Lmag, [min(Lmag(:)),max(Lmag(:))]);
% hold on
% plot(xpeakcrop, ypeakcrop, 'ro');
% hold off

% contour map
% imcontour(c);
% find highest value contour line, within region of x pixels around it,
% are there multiple contour line values??

end
