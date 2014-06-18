function [ Transforms, flag ] = xcorr2imgs( T, A, pad )
%XCORR2IMGS Rough alignment by 2D cross-correlation differing by
%translation and/or rotation. Assumed for scale to always be 1.
%   Computes the transformations that result in automated alignment between
%   template and A. 
%   [ tform, flag ] = xcorr2imgs( template, A )
%   [ tform, flag ] = xcorr2imgs( template, A, pad )
%   If the pad parameter is set to 'pad', then program will add extra
%   padding that helps with the integrity of taking fourier transforms,
%   though at the cost of more computation time. flag is raised if
%   alignment is deemed to fail.
%   ASSUMPTIONS: template and A are the SAME size, and DO NOT have any
%   zero pad. These assumptions are consistent with inputs from EM
%   sections.
%
%   Adapted from Reddy, Chatterji, An FFT-Based Technique for Translation,
%   Rotation, and Scale-Invariant Image Registration, 1996, IEEE Trans.

% retrieve global variables
global peakclassifier;

% whether to use a trained classifier
classify = 0;
if strcmpi(class(peakclassifier), 'ClassificationSVM')
    classifier = peakclassifier;
    classify = 1;
end

% validate inputs.
narginchk(2,3);
padaction = 0;
if nargin == 3 && strcmpi(pad, 'pad') % align and pad param
    padaction = 1;
end

% stop program early if one image is flat (all one color).
if std(double(T(:))) == 0 || std(double(A(:))) == 0
    warning('XCORR2IMGS: one image is completely flat; no transformations performed');
    Transforms = eye(3);
    flag = 1;
    return;
end

% flag to indicate failed alignment.
flag = 0;

% convert inputs to unsigned 8-bit integers.
A = uint8(A);
T = uint8(T);

% apply hamming window.
Amod = window2d(A, 'hamming');
Tmod = window2d(T, 'hamming');

% additional zero padding to avoid edge bias. Tests show this improves
% image alignment, but slows down program.
if padaction
    ypad = min(floor(size(Amod, 1)/2), floor(size(Tmod, 1)/2));
    xpad = min(floor(size(Amod, 2)/2), floor(size(Tmod, 2)/2));
    Amod = padarray(Amod, [ypad, xpad]);
    Tmod = padarray(Tmod, [ypad, xpad]);
end

% DFT of template and A.
Amod = fft2(Amod);
Tmod = fft2(Tmod);

% high-pass filtering.
Amod = highpass(abs(fftshift(Amod)));
Tmod = highpass(abs(fftshift(Tmod)));

% Resample image in log-polar coordinates.
[Tmod, ~] = log_polar(Tmod);
Amod = log_polar(Amod);
clear filteredFT filteredFA;

% compute phase correlation to find best theta.
xpowerspec = fft2(Amod).*conj(fft2(Tmod));
c = real(ifft2(xpowerspec.*(1/norm(xpowerspec))));
clear xpowerspec Amod Tmod;
[~, thetapeak] = find(c==max(c(:)));
th = (thetapeak - 1) * 360 / size(c, 2);
THETA1 = -th;
THETA2 = -th - 180;
clear c;

% rotate template image two possible ways.
RotatedT1 = imrotate(T, THETA1, 'nearest', 'crop');
RotatedT2 = imrotate(T, THETA2, 'nearest', 'crop');

% pick correct rotation by maximizing cross correlation. compute best
% transformation parameters.
[RotatedT1, ysmin1, xsmin1, ysmax1, xsmax1] = rmzeropadding(RotatedT1, 2);
[RotatedT2, ysmin2, xsmin2, ysmax2, xsmax2] = rmzeropadding(RotatedT2, 2);
Atemp1 = A(1+ysmin1:size(A,1)-ysmax1, 1+xsmin1:size(A,1)-xsmax1);
Atemp2 = A(1+ysmin2:size(A,1)-ysmax2, 1+xsmin2:size(A,1)-xsmax2);
c1 = normxcorr2(RotatedT1, Atemp1);
c2 = normxcorr2(RotatedT2, Atemp2);
if classify
    [y1, x1] = detectpeaksvm(c1, classifier);
    [y2, x2] = detectpeaksvm(c2, classifier);
else
    [y1, x1] = find(c1==max(c1(:)));
    [y2, x2] = find(c2==max(c2(:)));
end
if x1 == -1
    max1 = 0;
else
    max1 = c1(y1,x1);
end
if x2 == -1
    max2 = 0;
else
    max2 = c2(y2,x2);
end
select = 0;
if max1 > max2
    select = 1;
elseif max2 > max1
    select = 2;
end
clear c1 c2 Atemp1 Atemp2;
% pick rotation that produces the greatest peak
if select == 1
    RotatedT = RotatedT1;
    THETA = THETA1;
    TranslateY = y1 - size(RotatedT, 1);
    TranslateX = x1 - size(RotatedT, 2);
elseif select == 2
    RotatedT = RotatedT2;
    THETA = THETA2;
    TranslateY = y2 - size(RotatedT, 1);
    TranslateX = x2 - size(RotatedT, 2);
else
    THETA = 0;
    TranslateX = 0;
    TranslateY = 0;
    warning('failed alignment.');
    flag = 1;
end
clear RotatedT1 RotatedT2

% save transformations
Transforms = params2matrix([TranslateY, TranslateX, THETA]);

end
