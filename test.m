A = data1(:,:,4);
T = data1(:,:,5);
tform = xcorr2imgs(T, A);
params = matrix2params(tform);
RA = imref2d(size(A));
RT = imref2d(size(T));
[At, RAt] = imtranslate(A, RA, -floor(size(A)/2), 'OutputView', 'full');
[Tt, RTt] = imtranslate(T, RT, -floor(size(T)/2), 'OutputView', 'full');
rotmatrix = params2matrix([0, 0, params(3)]);
tmatrix = params2matrix([params(1:2), 0]);
rotmatrix*tmatrix
[Ttform, RTtform] = imwarp(Tt, RTt, affine2d(rotmatrix*tmatrix));
% [Ttform, RTtform] = imwarp(Ttform, RTtform, affine2d(tmatrix));
figure; imshowpair(At, RAt, Ttform, RTtform);

figure; imshow(At, RAt);
figure; imshow(Ttform, RTtform);