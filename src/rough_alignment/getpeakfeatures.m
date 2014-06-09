function [ features ] = getpeakfeatures( c, ypeak, xpeak ) 
% [ features ] = getpeakfeatures( c ) takes input image c, peak values of
% xpeak, ypeak, and returns a 1 x k vector with values of k features 

%gradient, Laplacian
[Gmag,Gdir] = imgradient(c);
features(1) = Gmag(ypeak,xpeak);
[Lmag,Ldir] = imgradient(Gmag);
features(2) = Lmag(ypeak,xpeak);

%histogram statistics  
meanGL = mean(double(c(:)));
varGL = var(double(c(:)));

[pixelCounts GLs] = imhist(c); %grayLevels = GLs
skew = sum((GLs-meanGL).^ 3 .*pixelCounts)/((sum(pixelCounts)-1)*varGL^1.5); 
kurtosis = kurtosis(double(c(:)));

features(3) = meanGL;
features(4) = varGL;
features(5) = skew; %negative skew = skewed left 
features(6) = kurtosis; 

end
