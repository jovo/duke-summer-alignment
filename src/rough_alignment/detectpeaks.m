function [ ypeak, xpeak ] = detectpeaks( oldC, tempsize, type, class )
%DETECTPEAKS Detects significant peaks of image in fourier domain.
%   [ xpeak, ypeak ] = detectpeaks( c, tempsize, type ) takes an image in
%   the fourier domain, c, and evaluates the peak. tempsize specifies the
%   distribution of the peak it should model. If program finds a potential
%   error in peak detection, will return -1 for all outputs;

% validate inputs
RT = strcmpi(class, 'rt');
YX = strcmpi(class, 'yx');
if ~strcmpi(class, 'rt') && ~strcmpi(class, 'yx')
    error('enter either rt or yx for class');
end

% construct the distribution that c will correlate with.
if strcmpi(type, 'gaussian')
    y = normpdf(-tempsize:tempsize, 0, 2);
elseif strcmpi(type, 'exp')
    y = exppdf(0:tempsize, 2);
    y = [fliplr(y), y];
end
template = y'*y;

% crop out parts that probably won't have peaks to improve efficiency.
cropy = 0;
cropx = 0;
if RT
    oldCcropped = oldC(1:floor(size(oldC,1)/6), :);
elseif YX
    cropy = floor(size(oldC,1)/4);
    cropx = floor(size(oldC,2)/4);
    oldCcropped = oldC(1+cropy: size(oldC,1)-cropy, 1+cropx: size(oldC,2)-cropx);
end

% add symmetric padding if calculating rho/theta.
if RT
    padsize = tempsize;
    oldCpad = padarray(oldCcropped, [tempsize, tempsize], 'symmetric');
elseif YX
    padsize = 0;
    oldCpad = oldCcropped;
end
% correlate old image with a peak shaped distribution for new peak
newCpad = normxcorr2(template, oldCpad);
bounds = tempsize + padsize;
newCcropped = newCpad(bounds+1:size(newCpad,1)-bounds, bounds+1:size(newCpad,2)-bounds);
newC = padarray(newCcropped, [cropy, cropx], 0);
% find old and new peaks
[ypeakold, xpeakold] = find(oldC==max(oldC(:)));
[ypeaknew, xpeaknew] = find(newC==max(newC(:)));

% debugging
size(oldC)
size(newC)
figure; imshow(oldC,[min(oldC(:)), max(oldC(:))]);
hold on;
plot(xpeakold,ypeakold,'ro');
hold off;
figure; imshow(newC,[min(newC(:)), max(newC(:))]);
hold on;
plot(xpeaknew,ypeaknew,'go');
hold off;

% enter final values for xpeak and ypeak. if peaks are not unique, then
% reject unless peaks are really close together. if the distance between
% old and new peaks are less than a certain realistic distance away, then
% use the old peak location. Otherwise, use the newer, probably better peak
% location.
if length(xpeaknew) > 1 && ...  % non-unique maxima
       sqrt((ypeaknew(1)-ypeaknew(2))^2 + (xpeaknew(1)-xpeaknew(2))^2) > 3
    xpeak = -1;
    ypeak = -1;
elseif sqrt((ypeaknew(1)-ypeakold(1))^2 + (xpeaknew(1)-xpeakold(1))^2) < 10
    xpeak = xpeakold(1);
    ypeak = ypeakold(1);
else
    xpeak = xpeaknew(1);
    ypeak = ypeaknew(1);
end

end

