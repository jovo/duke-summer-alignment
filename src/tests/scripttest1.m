

template = imageAC4(1:1000, 1:1000, 1);
A = imageAC4(1:1000, 1:1000, 1);
A = A(200:800,200:800);
template2 = imrotate(template, 98);
template2 = template2(200:800,200:800);
figure; imshowpair(A, template2, 'montage')
[tform,merged] = xcorr2imgs(template2, A,'align','pad');
figure; imshowpair(merged(:,:,1), merged(:,:,2), 'diff');

% c = normxcorr2(template, A);
% figure; imshow(c, [min(c(:)),max(c(:))]);
% [tform, merged] = featurematch2imgs(template, A, 0.5);





% % images different size, correlate rotation
% A = imageAC4(1:512, 1:512, 1);
% template = imageAC4(1:100, 1:100, 1);
% 
% % pad to same size?
% yaddpad = max(size(A, 1), size(template, 1));
% xaddpad = max(size(A, 2), size(template, 2));
% A = padarray(A, [yaddpad-size(A, 1), xaddpad-size(A, 2)], 0, 'post');
% template = padarray(template, [yaddpad-size(template, 1), xaddpad-size(template, 2)], 0 ,'post');
% Aham = hamming2dwindow(A);
% templateham = hamming2dwindow(template);
% 
% 
%     ypadd = min(floor(size(A, 1)/2), floor(size(templateham, 1)/2));
%     xpadd = min(floor(size(A, 2)/2), floor(size(templateham, 2)/2));
%     Aham = padarray(Aham, [ypadd, xpadd]);
%     templateham = padarray(templateham, [ypadd, xpadd]);
% 
% c1 = normxcorr2(template,A);
% c2 = normxcorr2(templateham,Aham);
% figure; imshowpair(c1, c2, 'montage');