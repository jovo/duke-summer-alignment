function [ Merged, MergedStack ] = xcorr2imgs( template, A, templateStack, AStack )
%XCORR2IMGS Rough alignment by 2D cross-correlation differing scaling,
%translation, and/or rotation.
%
%   Adapted from Reddy, Chatterji, An FFT-Based Technique for Translation,
%   Rotation, and Scale-Invariant Image Registration, 1996, IEEE Trans.
%
%   [ T_new, A_new, Merged, THETA, SCALE ] = XCORR2IMGS( template, A )
%   template is the image that should be matched to A. A should be
%   larger than template or of same size. If that is not the case, will try to
%   crop/swap images to satisfy these conditions.
%   NOTE:
%   It is preferred for template and A to be the same size.
%   Please avoid zero padding that cover potential image overlaps. This causes
%   significant bias and the program will probably fail.
%   one image MUST be less than 1.5x smaller or larger than other image.

% convert to grayscale as necessary.
if size(A, 3) == 3
    A = rgb2gray(A);
end
if size(template, 3) == 3
    template = rgb2gray(template);
end

% adjust image dimensions as necessary
switch sum(size(A) >= size(template))
    case 0  % A is completely smaller than template: swap.
        templatetemp = template;
        template = A;
        A = templatetemp;
    case 1  % A is smaller than template in 1 dimension: crop template.
        miny = min(size(template, 1), size(A, 1));
        minx = min(size(template, 2), size(A, 2));
        template = template(1:miny, 1:minx);
end

% DFT of template and A.
FourierT = fft2(template);
FourierA = fft2(A);

% high-pass filtering.
filteredFT = highpass(abs(fftshift(FourierT)));
filteredFA = highpass(abs(fftshift(FourierA)));

% Resample image in log-polar coordinates.
[LogPolarT, rhoaxis] = log_polar(filteredFT);
LogPolarA = log_polar(filteredFA);

% compute phase correlation to find best theta.
ysize = max(size(LogPolarA, 1), size(LogPolarT, 1));
xsize = max(size(LogPolarA, 2), size(LogPolarT, 2));
c = real(ifft2(fft2(LogPolarA, ysize, xsize).*conj(fft2(LogPolarT, ysize, xsize))));
[rhopeak, thetapeak] = find(c==max(c(:)));
if rhopeak > size(c, 1)/2    % template scaled down to match A
    rhoindex = size(c,1) - rhopeak + 1;
    SCALE = 1/rhoaxis(rhoindex);
else    % template scaled up to match A
    SCALE = rhoaxis(rhopeak);
end
if SCALE > 1.5 || SCALE < 1/1.5     % threshold against excessive/wrong scaling
    SCALE = 1;
    THETA = 0;
else
    THETA = (thetapeak - 1) * 360 / size(c, 2);
end

% rotate template image two possible ways.
RotatedT1 = imrotate(template, -THETA, 'nearest', 'crop');
RotatedT2 = imrotate(template, -THETA-180, 'nearest', 'crop');

% scale each potential template image
RotatedT1 = imresize(RotatedT1, 1/SCALE);
RotatedT2 = imresize(RotatedT2, 1/SCALE);

% pick correct rotation by maximizing cross correlation. compute best
% transformation parameters.
[RotatedT1padrm, yshifted1, xshifted1] = rmzeropaddingforced(RotatedT1);
[RotatedT2padrm, yshifted2, xshifted2] = rmzeropaddingforced(RotatedT2);
c1 = normxcorr2(RotatedT1padrm, A);
c2 = normxcorr2(RotatedT2padrm, A);
[y1, x1] = find(c1==max(c1(:)));
[y2, x2] = find(c2==max(c2(:)));
if c1(y1, x1) > c2(y2, x2)
    RotatedTpadrm = RotatedT1padrm;
    THETA = -THETA;
    TranslateY = y1 - size(RotatedTpadrm, 1) - yshifted1 + 2;
    TranslateX = x1 - size(RotatedTpadrm, 2) - xshifted1 + 2;
else
    RotatedTpadrm = RotatedT2padrm;
    THETA = -THETA - 180;
    TranslateY = y2 - size(RotatedTpadrm, 1) - yshifted2 + 2;
    TranslateX = x2 - size(RotatedTpadrm, 2) - xshifted2 + 2;
end
TranslateY = floor(TranslateY);
TranslateX = floor(TranslateX);

% Perform translation, rotation, scaling transformations to images
T = imrotate(imresize(template, 1/SCALE), THETA, 'nearest', 'crop');
TStack = imrotate(imresize(templateStack, 1/SCALE), THETA, 'nearest', 'crop');
Ay = size(A, 1);
Ax = size(A, 2);
Ty = size(T, 1);
Tx = size(T, 2);
new_y = max(Ay, max(abs(TranslateY) + Ty, abs(TranslateY) + Ay));
new_x = max(Ax, max(abs(TranslateX) + Tx, abs(TranslateX) + Ax));
A_new = zeros(new_y, new_x);
T_new = A_new;

depthA = size(AStack, 3);
depthT = size(TStack, 3);
AStacky = size(AStack, 1);
AStackx = size(AStack, 2);
TStacky = size(TStack, 1);
TStackx = size(TStack, 2);
newstack_y = max(AStacky, max(abs(TranslateY) + TStacky, abs(TranslateY) + AStacky));
newstack_x = max(AStackx, max(abs(TranslateX) + TStackx, abs(TranslateX) + AStackx));
AStack_new = zeros(newstack_y, newstack_x, depthA);
TStack_new = zeros(newstack_y, newstack_x, depthT);

if TranslateY > 0
    Ayrange = 1:Ay;
	Tyrange = (1:Ty) + TranslateY;
    Ayrangestack = 1:AStacky;
    Tyrangestack = (1:TStacky) + TranslateY;
    if TranslateX > 0
        Axrange = 1:Ax;
        Txrange = (1:Tx) + TranslateX;
        Axrangestack = 1:AStackx;
        Txrangestack = (1:TStackx) + TranslateX;
    else
        Axrange = (1:Ax) + abs(TranslateX);
        Txrange = 1:Tx;
        Axrangestack = (1:AStackx) + abs(TranslateX);
        Txrangestack = 1:TStackx;
    end
else
    Ayrange = (1:Ay) + abs(TranslateY);
    Tyrange = 1:Ty;
    Ayrangestack = (1:AStacky) + abs(TranslateY);
    Tyrangestack = 1:TStacky;
    if TranslateX > 0
        Axrange = 1:Ax;
        Txrange = (1:Tx) + TranslateX;
        Axrangestack = 1:AStackx;
        Txrangestack = (1:TStackx) + TranslateX;
    else
        Axrange = (1:Ax) + abs(TranslateX);
        Txrange = 1:Tx;
        Axrangestack = (1:AStackx) + abs(TranslateX);
        Txrangestack = 1:TStackx;
    end
end

A_new(Ayrange, Axrange) = A;
T_new(Tyrange, Txrange) = T;
AStack_new(Ayrangestack, Axrangestack, :) = AStack;
TStack_new(Tyrangestack, Txrangestack, :) = TStack;

% remove padded zeros from final image.
Merged = A_new;
empty = find(T_new~=0);
Merged(empty) = T_new(empty);
[ycoord, xcoord] = find(Merged);
Merged = Merged(min(ycoord):max(ycoord), min(xcoord):max(xcoord));
MergedStack = cat(3, TStack_new, AStack_new);
% MergedStack = MergedStack(min(ycoord):max(ycoord), min(xcoord):max(xcoord),:);


%% Helper functions

    % simple high-pass emphasis filter
    function [M_hip] = highpass( M )
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

    % removes zero padding as much as possible; might crop parts of image.
    function [ M_new, yshift, xshift ] = rmzeropaddingforced( M )
        % remove horizontal/vertical padding
        [ypad, xpad] = find(M);
        M_new = M(min(ypad):max(ypad), min(xpad):max(xpad));
        yshift = min(ypad);
        xshift = min(xpad);
        % remove diagonal padding: will probably crop parts of image.
        ymin = 1;
        xmin = 1;
        ymax = size(M_new,1);
        xmax = size(M_new,2);
        while (M_new(ymin, xmin) + M_new(ymin, xmax) + M_new(ymax, xmin) + M_new(ymax, xmax)) == 0 ...
                && ymax > ymin && xmax > xmin
            xmin = xmin+1;
            xmax = xmax-1;
            ymin = ymin+1;
            ymax = ymax-1;
        end
        yshift = yshift + ymin;
        xshift = xshift + xmin;
        M_new = M_new(ymin:ymax, xmin:xmax);
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

end

