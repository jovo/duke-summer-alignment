function [ tform ] = featurematch2imgs( T, A, resize )
%MATCHLOCALFEATURES Match local features with feature detection/matching.
%   [ tform ] = matchlocalfeatures( T, A )
%   [ tform ] = featurematch2imgs( T, A, resize ) T is the image that
%   should be matched to A. scale parameter indicates how much to scale the
%   image before feature matching to improve efficiency. Realistically, the
%   parameter should be 0.5 <= scale <= 1.

% convert inputs to unsigned 8-bit integers.
A = uint8(A);
T = uint8(T);

% apply gaussian blur to filter noise and resize as specified.
hsizeA = floor(size(A)/100);
hsizeT = floor(size(T)/100);
sigmaA = floor(size(A,1)/200);
sigmaT = floor(size(T,1)/200);
F1 = fspecial('gaussian', hsizeA, sigmaA);
F2 = fspecial('gaussian', hsizeT, sigmaT);

% validate inputs
if nargin > 2
    Ascaled = imresize(imfilter(A, F1), resize);
    Tscaled = imresize(imfilter(T, F2), resize);
else
    Ascaled = imfilter(A, F1);
    Tscaled = imfilter(T, F2);
end

% detect surf features
pointsA = detectSURFFeatures(Ascaled);
pointsT = detectSURFFeatures(Tscaled);
[featuresA, vptsA] = extractFeatures(Ascaled, pointsA);
[featuresT, vptsT] = extractFeatures(Tscaled, pointsT);

% match features
indexPairs = matchFeatures(featuresA, featuresT, 'Prenormalized', true);
matchptsA = vptsA(indexPairs(:, 1));
matchptsT = vptsT(indexPairs(:, 2));
try
    [geotform, ~, ~] = estimateGeometricTransform(matchptsT, matchptsA, 'affine');
catch
    geotform = affine2d(eye(3));
end

% determine rotation parameter, r1
featuret = matrix2params(geotform.T);
r1 = params2matrix([0, 0, featuret(3)]);

% transform input by r1 and use as input to xcorr2imgs
merged = affinetransform(T, A, r1);
[newT, ycutmin, xcutmin, ycutmax, xcutmax] = rmzeropadding(merged(:,:,1), 1);
newA = A(1+ycutmin:size(A,1)-ycutmax, 1+xcutmin:size(A,2)-xcutmax);
t2r2 = xcorr2imgs(newT, newA, 'pad');

% compute overall transformation
r2 = [ [t2r2(1:2,1:2),[0;0]]; [0,0,1] ];
t2 = t2r2/r2;
tform = t2*r1*r2;

end
