function [ updatedtform, merged ] = featurematch2imgs( T, A, resize )
%MATCHLOCALFEATURES Match local features with feature detection/matching.
%   [ T_new ] = matchlocalfeatures( T, A, resize ) T is the image that
%   should be matched to A. scale should probably be <= 1, and scales the
%   images before matching to improve efficiency. Where xcorr sometimes
%   struggles to accurately detect rotation, this does a better job. 

    % apply median filter to filter noise and resize as specified.
    Ascaled = imresize(medfilt2(A, [10,10]), resize);
    Tscaled = imresize(medfilt2(T, [10,10]), resize);

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
%     figure; showMatchedFeatures(Ascaled, Tscaled, matchptsA, matchptsT, 'montage');
    [tform, inlierT, inlierA] = estimateGeometricTransform(matchptsT, matchptsA, 'affine');
%     figure; showMatchedFeatures(Ascaled, Tscaled, inlierA,inlierT, 'montage');

    % determine transformations
    tparams = matrix2params(tform.T);
    tparams(1:2) = [0,0];
    scale = tparams(4);
    tparams(4) = 1;
    curtform = params2matrix(tparams);
    if scale < 1.05
        tempmerged = affinetransform(T, A, curtform);
        T_new = rmzeropadding(tempmerged(:,:,1));
        [newtform, merged] = xcorr2imgs(T_new, A, 'align', 1);
        updatedtform = curtform*newtform;
    else
        updatedtform = eye(3);
        merged = affinetransform(T, A, eye(3));
    end

%     figure, imshowpair(A, T_new, 'montage')

end