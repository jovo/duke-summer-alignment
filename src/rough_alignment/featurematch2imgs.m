function [ updatedtform, merged ] = featurematch2imgs( T, A, resize )
%MATCHLOCALFEATURES Match local features with feature detection/matching.
%   [ updatedtform, merged ] = matchlocalfeatures( T, A )
%   [ updatedtform, merged ] = featurematch2imgs( T, A, resize ) T is the
%   image that should be matched to A. scale should probably be <= 1, and
%   scale the images before matching to improve efficiency. If feature
%   matching does a poor job, reverts back to xcorr methods.

% retrieve global variable
global scalethreshold;
if isempty(scalethreshold)
    scalethreshold = 1.05;
end

% threshold for possible image scaling.
threshold = scalethreshold;

% convert inputs to unsigned 8-bit integers.
A = uint8(A);
T = uint8(T);

% apply median filter to filter noise and resize as specified.
if nargin > 2
    Ascaled = imresize(medfilt2(A, [10,10]), resize);
    Tscaled = imresize(medfilt2(T, [10,10]), resize);
else
    Ascaled = medfilt2(A, [10,10]);
    Tscaled = medfilt2(T, [10,10]);
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
tparams = [0, 0, featuret(3), 1];
prevtform = params2matrix(tparams);
if featuret(4) < threshold || featuret(4) > 1/threshold
    tempmerged = affinetransform(T, A, prevtform);
    [newT,ycutmin, xcutmin, ycutmax, xcutmax] = rmzeropadding(tempmerged(:,:,1), 1);
    newA = A(1+ycutmin:size(A,1)-ycutmax, 1+xcutmin:size(A,2)-xcutmax);
    [newtform,merged] = xcorr2imgs(newT, newA, 'align', 'pad');
%     figure; imshowpair(merged(:,:,1), merged(:,:,2), 'montage');
    updatedtform = prevtform * newtform;
    merged = affinetransform(T, A, updatedtform);
else
    [updatedtform, merged] = xcorr2imgs(T, A, 'align', 'pad');
end

end
