function [ updatedtform, merged ] = featurematch2imgs( T, A, resize )
%MATCHLOCALFEATURES Match local features with feature detection/matching.
%   [ updatedtform, merged ] = matchlocalfeatures( T, A )
%   [ updatedtform, merged ] = featurematch2imgs( T, A, resize ) T is the
%   image that should be matched to A. scale should probably be <= 1, and
%   scale the images before matching to improve efficiency. If feature
%   matching does a poor job, reverts back to xcorr methods.

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
    [tform, ~, ~] = estimateGeometricTransform(matchptsT, matchptsA, 'affine');
catch
    tform = affine2d(eye(3));
end

% determine transformations
featuret = matrix2params(tform.T);
tparams = [0, 0, featuret(3)];
prevtform = params2matrix(tparams);
tempmerged = affinetransform(T, A, prevtform);
[newT,ycutmin, xcutmin, ycutmax, xcutmax] = rmzeropadding(tempmerged(:,:,1), 1);
newA = A(1+ycutmin:size(A,1)-ycutmax, 1+xcutmin:size(A,2)-xcutmax);
[newtform, ~] = xcorr2imgs(newT, newA, 'align', 'pad');
updatedtform = prevtform * newtform;
merged = affinetransform(T, A, updatedtform);
end
