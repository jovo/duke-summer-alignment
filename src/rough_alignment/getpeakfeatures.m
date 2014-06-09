function [ features ] = getpeakfeatures( c, ypeak, xpeak ) 
% [ features ] = getpeakfeatures( c ) takes input image c, peak values of
% xpeak, ypeak, and returns a 1 x k vector with values of k features 

%gradient, Laplacian
[Gmag,Gdir] = imgradient(c);
features(1) = Gmag(ypeak,xpeak);
[Lmag,Ldir] = imgradient(Gmag);
features(2) = Lmag(ypeak,xpeak);

%histogram statistics  
features(3) = mean(double(c(:)));
features(4) = var(double(c(:)));
features(5) = skewness(double(c(:))); %negative skew = skewed left 
features(6) = kurtosis(double(c(:))); 

end
