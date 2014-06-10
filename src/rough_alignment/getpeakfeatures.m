function [ features ] = getpeakfeatures( img, ypeak, xpeak ) 
% [ features ] = getpeakfeatures( img ) takes input image img, peak values 
% xpeak, ypeak, and returns a 1 x k vector with values of k features 

sz = size(img,3);
features = NaN(sz,7); 

for i = 1:sz
    c = img(:,:,i); 

%gradient, Laplacian
[Gmag, ~] = imgradient(c);
features(1,1) = Gmag(ypeak,xpeak);
[Lmag, ~] = imgradient(Gmag);
features(1,2) = Lmag(ypeak,xpeak);

%histogram statistics  
features(1,3) = mean(double(c(:)));
features(1,4) = var(double(c(:)));
features(1,5) = skewness(double(c(:))); %negative skew = skewed left 
features(1,6) = kurtosis(double(c(:)));

%counts # pixels within certain range (exp correct = small)
cBinary = roicolor(c,230,255);
[ymax, xmax, value] = find(cBinary);
features(1,7) = size(ymax,1); 

%edge values

end

end
