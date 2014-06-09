function [ features ] = getpeakfeatures( c, ypeak, xpeak ) 
% [ features ] = getpeakfeatures( c ) takes input image c, peak values of
% xpeak, ypeak, and returns a 1 x k vector with values of k features 

features = NaN(1,6);
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

end
