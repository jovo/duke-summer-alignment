function [ merged ] = matchlocalfeatures( T, A )
%MATCHLOCALFEATURES Match local features with feature detection/matching.
%   Detailed explanation goes here

    % detect surf features
	pointsA = detectSURFFeatures(A);
	pointsT = detectSURFFeatures(T);
    [featuresA, vptsA] = extractFeatures(A, pointsA);
    [featuresT, vptsT] = extractFeatures(T, pointsT);

    % match features
	indexPairs = matchFeatures(featuresA, featuresT, 'Prenormalized', true);
    matchptsA = vptsA(indexPairs(:, 1));
    matchptsT = vptsT(indexPairs(:, 2));
    figure; showMatchedFeatures(A, T, matchptsA, matchptsT, 'montage');
    [tform, inlierT, inlierA] = estimateGeometricTransform(matchptsT, matchptsA, 'affine');
    figure; showMatchedFeatures(A, T, inlierA,inlierT, 'montage');

    % determine transformations
    tparams = matrix2params(tform.T);
    tparams(1:2) = [0,0];
    scale = tparams(4);
    tparams(4) = 1;
    tmatrix = params2matrix(tparams);
    prevparam = [0,0,0,1,0];
    prevtform = {prevparam; affine2d(params2matrix(prevparam))};
    curtform = {tparams, affine2d(tmatrix)};
    if scale < 1.05
        merged = affinetransform(T, A, curtform, prevtform);
        T_new = rmzeropadding(merged(:,:,1));
    else
        T_new = T;
    end

    merged = cat(3, T_new, A);
    figure, imshowpair(A, T_new, 'montage')

end

