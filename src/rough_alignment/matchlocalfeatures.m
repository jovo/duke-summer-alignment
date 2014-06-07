function [ T_new ] = matchlocalfeatures( T, A, resize )
%MATCHLOCALFEATURES Match local features with feature detection/matching.
%   [ T_new ] = matchlocalfeatures( T, A, resize ) T is the image that
%   should be matched to A. scale should probably be <= 1, and scales the
%   images before matching to improve efficiency.

    Ascaled = imresize(A, resize);
    Tscaled = imresize(T, resize);

    % convert inputs to unsigned 8-bit integers.
    Ascaled = uint8(Ascaled);
    Tscaled = uint8(Tscaled);

    % detect surf features
	pointsA = detectSURFFeatures(Ascaled);
	pointsT = detectSURFFeatures(Tscaled);
    [featuresA, vptsA] = extractFeatures(Ascaled, pointsA);
    [featuresT, vptsT] = extractFeatures(Tscaled, pointsT);

    % match features
	indexPairs = matchFeatures(featuresA, featuresT, 'Prenormalized', true);
    matchptsA = vptsA(indexPairs(:, 1));
    matchptsT = vptsT(indexPairs(:, 2));
%     figure; showMatchedFeatures(A, T, matchptsA, matchptsT, 'montage');
    [tform, inlierT, inlierA] = estimateGeometricTransform(matchptsT, matchptsA, 'affine');
%     figure; showMatchedFeatures(Ascaled, Tscaled, inlierA,inlierT, 'montage');

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

%     figure, imshowpair(A, T_new, 'montage')

end