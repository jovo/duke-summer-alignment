function [ Transforms, Merged ] = xcorr2imgs( template, A, varargin )
%XCORR2IMGS Rough alignment by 2D cross-correlation differing by
%translation and/or rotation.
%   Performs automated alignment to template and A. performs the same
%   transformations to templateStack and AStack, respectively.
%   [ Transforms ] = xcorr2imgs( template, A )
%   [ Transforms, Merged ] = xcorr2imgs( template, A, align )
%   [ Transforms, Merged ] = xcorr2imgs( template, A, align, pad )
%   if align is true (1), then also outputs the transformed final image in
%   Merged. otherwise Merged is nil.
%   if pad is true (1), then will zero pad to improve alignment, but
%   increase running time.
%
%   Adapted from Reddy, Chatterji, An FFT-Based Technique for Translation,
%   Rotation, and Scale-Invariant Image Registration, 1996, IEEE Trans.
%
% validate inputs
narginchk(2,4);
align = 0;
pad = 0;
if nargin > 2 && strcmpi(varargin{1}, 'align')  % align param
	align = 1;
end
if nargin > 3 && strcmpi(varargin{2}, 'pad') % align and pad param
    pad = 1;
end

% stop program early if one image is flat (all one color)
if std(double(template(:))) == 0 || std(double(A(:))) == 0
    warning('one image is completely flat; no transformations performed');
    identparams = [0,0,0,1,1];
    Transforms = {identparams; affine2d(params2matrix(identparams))};
    if std(double(template(:))) == 0
        Merged = A;
    else
        Merged = template;
    end
    return;
end

% threshold for possible image scaling, which shouldn't happen by
% assumption.
threshold = 1.05;

% convert to grayscale as necessary. (TODO Assumed to be greyscale)
% if size(A, 3) == 3
%     A = rgb2gray(A);
% end
% if size(template, 3) == 3
%     template = rgb2gray(template);
% end

% adjust image dimensions as necessary
switch sum(size(A) >= size(template))
    case 0  % A is completely smaller than template: swap.
        templatetemp = template;
        template = A;
        A = templatetemp;
        clear templatetemp;
    case 1  % A is smaller than template in 1 dimension: crop template.
        miny = min(size(template, 1), size(A, 1));
        minx = min(size(template, 2), size(A, 2));
        template = template(1:miny, 1:minx);
end

% zero pad image to same size
if size(A) ~= size(template)
    yaddpad = max(size(A, 1), size(template, 1));
    xaddpad = max(size(A, 2), size(template, 2));
    A = padarray(A, [yaddpad-size(A, 1), xaddpad-size(A, 2)], 0, 'post');
    template = padarray(template, [yaddpad-size(template, 1), xaddpad-size(template, 2)], 0 ,'post');
end

% apply hamming window
Aham = hamming2dwindow(A);
templateham = hamming2dwindow(template);

% additional zero padding to avoid edge bias. Tests show this improves
% image alignment, but slows down program.
if pad
    ypadd = min(size(A, 1), size(templateham, 1));
    xpadd = min(size(A, 2), size(templateham, 2));
    Aham = padarray(Aham, [ypadd, xpadd]);
    templateham = padarray(templateham, [ypadd, xpadd]);
end

% DFT of template and A.
FourierT = fft2(templateham);
FourierA = fft2(Aham);
clear Aham templateham;

% high-pass filtering.
filteredFT = highpass(abs(fftshift(FourierT)));
filteredFA = highpass(abs(fftshift(FourierA)));
clear FourierA FourierT;

% Resample image in log-polar coordinates.
[LogPolarT, rhoaxis] = log_polar(filteredFT);
LogPolarA = log_polar(filteredFA);
clear filteredFT filteredFA;

% compute phase correlation to find best theta.
xpowerspec = fft2(LogPolarA).*conj(fft2(LogPolarT));
c = real(ifft2(xpowerspec.*(1/norm(xpowerspec))));
[rhopeak, thetapeak] = detectpeaks(c, ceil(length(c)/8), 'gaussian', 'rt');
if rhopeak == -1    % peak detection failed
    SCALE = 1;
    THETA1 = 0;
    THETA2 = 0;
else
    if rhopeak > size(c, 1)/2    % template scaled down to match A
        rhoindex = size(c,1) - rhopeak + 1;
        SCALE = 1/rhoaxis(rhoindex);
    else    % template scaled up to match A
        SCALE = rhoaxis(rhopeak);
    end
    % assume scaling is always 1 for now.
    if SCALE > threshold || SCALE < 1/threshold     % threshold against excessive/wrong scaling
        SCALE = 1;
        THETA1 = 0;
        THETA2 = 0;
        warning('scaling exceeded threshold. Potentially failed alignment');
    else
        SCALE = 1;
        th = (thetapeak - 1) * 360 / size(c, 2);
        THETA1 = -th;
        THETA2 = -th - 180;
    end
end
clear LogPolarT LogPolarA;

% rotate template image two possible ways.
RotatedT1 = imrotate(template, THETA1, 'nearest', 'crop');
RotatedT2 = imrotate(template, THETA2, 'nearest', 'crop');

% scale each potential template image
if SCALE ~= 1
    RotatedT1 = imresize(RotatedT1, 1/SCALE);
    RotatedT2 = imresize(RotatedT2, 1/SCALE);
end

% pick correct rotation by maximizing cross correlation. compute best
% transformation parameters.
[RotatedT1padrm, yshifted1, xshifted1] = rmzeropadding(RotatedT1, 'force');
[RotatedT2padrm, yshifted2, xshifted2] = rmzeropadding(RotatedT2, 'force');
clear RotatedT1 RotatedT2;
c1 = normxcorr2(RotatedT1padrm, A);
c2 = normxcorr2(RotatedT2padrm, A);
[y1, x1] = detectpeaks(c1, ceil(length(c1)/8), 'gaussian', 'yx');
[y2, x2] = detectpeaks(c2, ceil(length(c2)/8), 'gaussian', 'yx');
if x1 == -1
    max1 = 0;
else
    max1 = c1(y1, x1);
end
if x2 == -1
    max2 = 0;
else
    max2 = c2(y2, x2);
end
clear c1 c2;
% pick rotation that produces the greatest peak
if max1 > max2
    RotatedTpadrm = RotatedT1padrm;
    THETA = THETA1;
    TranslateY = y1 - size(RotatedTpadrm, 1) - yshifted1 + 2;
    TranslateX = x1 - size(RotatedTpadrm, 2) - xshifted1 + 2;
    failed = 0;
elseif max1 < max2
    RotatedTpadrm = RotatedT2padrm;
    THETA = THETA2;
    TranslateY = y2 - size(RotatedTpadrm, 1) - yshifted2 + 2;
    TranslateX = x2 - size(RotatedTpadrm, 2) - xshifted2 + 2;
    failed = 0;
else
    failed = 1;
    THETA = 0;
    TranslateX = 0;
    TranslateY = 0;
end
clear RotatedT1padrm RotatedT2padrm

% save transformations
params = [TranslateY, TranslateX, THETA, SCALE, failed];
Transforms = {  params; affine2d(params2matrix(params))};

% if align is true, applies transformations
Merged = [];
if align
    identparams = [0,0,0,1,0];
    identT = {identparams; affine2d(params2matrix(identparams))};
    Merged  = affinetransform(template, A, Transforms, identT);
end

%% Helper functions

    % simple high-pass emphasis filter
    function [ M_hip ] = highpass( M )
        X = cos(linspace(-0.5,0.5,size(M,1)))'*cos(linspace(-0.5,0.5, size(M,2)));
        H = (1-X).*(2-X);   % transfer function
        M_hip = M.*H;
    end

    % log-polar representation of each Xcoord and Ycoord value of 2d matrix M
    function [ M_logpol, rho ] = log_polar( M )
        [sizey, sizex] = size(M);
        minsize = min(sizey, sizex);
        halfminsize = minsize*0.5;
        rho = logspace(0,log10(halfminsize),minsize);
        theta = linspace(0,2*pi,minsize+1);
        theta(length(theta)) = [];

        X = rho'*cos(theta) + halfminsize;
        Y = rho'*sin(theta) + halfminsize;
        M_logpol = interp2(M,X,Y);
        M_logpol((Y>sizey) | (Y<1) | (X>sizex) | (X<1)) = 0;
    end

    % apply a hamming window entirely to image matrix.
    function [ M_new ] = hamming2dwindow( M )
        M = double(M);
        ywindow = hamming(size(M, 1));
        xwindow = hamming(size(M, 2));
        w = ywindow(:) * xwindow(:)';
        M_new = M.*w;
    end

end



%% kind of buggy, maybe useful later?
%     % pick the better rotation
%     c1 = real(ifft2(FourierA.*conj(fft2(RotatedT1))));
%     c2 = real(ifft2(FourierA.*conj(fft2(RotatedT2))));
%     [y1, x1] = find(c1==max(c1(:)));
%     [y2, x2] = find(c2==max(c2(:)));
%     if c1(y1, x1) > c2(y2, x2)
%         RotatedT = RotatedT1;
%         y = y1;
%         x = x1;
%     else
%         RotatedT = RotatedT2;
%         y = y2;
%         x = x2;
%     end
%     % determine translation
%     TranslateY = y - 1;
%     TranslateX = x - 1;
%     if (y > size(A, 2)/2)
%         TranslateY = TranslateY - size(A, 2);
%     end
%     if (x > size(A, 1)/2)
%         TranslateX = TranslateX - size(A, 1);
%     end


% great debugging tool below.
% figure
% imshow(c, [min(c(:)), max(c(:))]);
% figure
% imshow(c, [0, 255]);
% ycoords = (1:size(A,1))+floor(size(template,1)/2)
% xcoords = (1:size(A,2))+floor(size(template,2)/2)
% c(ycoords, xcoords) = A;
% imshow(c, [0, 255]);
% 
% ytrans = (1:size(template,1))+ypeak-floor(size(template,1)/2);
% xtrans = (1:size(template,2))+xpeak-floor(size(template,2)/2);
% c(ytrans, xtrans) = template;
% imshow(c, [0, 255]);
