function [ features ] = getpeakfeatures( img, ypeak, xpeak ) 
% [ features ] = getpeakfeatures( img ) takes input image img, peak values 
% xpeak, ypeak, and returns a 1 x k vector with values of k features 

% define sizes
sizeyimg = size(img,1);
sizeximg = size(img,2);
cropsy = floor(sizeyimg/30);
cropsx = floor(sizeximg/30);

% normalize to between 0 and 255 and convert to uint8
img = img-min(img(:));  % minimum = 0
img = uint8(img.*(255/max(img(:))));    % range from 0 to 255

% regionprops on binary image
bw = im2bw(img, 0.8);
rp = regionprops(bw);

% padarray (in case peak is at edge) and update peak location
imgpad = padarray(img, [cropsy, cropsx], 'symmetric');
yp = ypeak+cropsy;
xp = xpeak+cropsx;

% crop padded image
cropped = imgpad(yp-cropsy:yp+cropsy, xp-cropsx:xp+cropsx);

% compute Gradient and  Laplacian
[Gmag, ~] = imgradient(cropped);
[Lmag, ~] = imgradient(Gmag);

% extract feature vector
features = NaN(1,5);
features(1) = sizeyimg*sizeximg;    % # of pixels
features(2) = rp.Area;  % area of binary 'on' region
features(3) = max(max(Gmag));
features(4) = max(max(Lmag));
features(5) = skewness(double(cropped(:)));

% ypeakcrop = 1+cropsy;
% xpeakcrop = 1+cropsx;
% figure; subplot(2,1,1);  subimage(cropped);
% hold on
% plot(xpeakcrop, ypeakcrop, 'ro');
% hold off
% subplot(2,1,2); subimage(bw);

end
