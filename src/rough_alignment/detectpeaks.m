function [ xpeak, ypeak ] = detectpeaks( c, type )
%DETECTPEAKS Detects significant peaks of image in fourier domain.
%   [ xpeak, ypeak ] = detectpeaks( c, type ) takes an image in the fourier
%   domain, c, and what the peak should be modelled after. If the maximum
%   point in c is indeed a 'peak', then returns the peak. Otherwise return
%   -1

tempsize = ceil(max(size(c))/8);    % half the size of distribution

% construct the distribution, template, that c will correlate with
if strcmpi(type, 'gaussian');
    y = normpdf(-tempsize:tempsize, 0, 2);
elseif strcmpi(type, 'exp');
    y = exppdf(0:tempsize, 5);
    y = [fliplr(y), y];
end
template = y'*y;

% correlate and find new peaks
[ypeakold, xpeakold] = find(c==max(c(:)));
x = normxcorr2(template, c);
[yp, xp] = find(x==max(x(:)));
ypeaknew = yp-tempsize;
xpeaknew = xp-tempsize;
% max(c(:))
% max(x(:))
% figure; imshow(c,[min(c(:)), max(c(:))]);
% hold on;
% plot(xpeakold,ypeakold,'ro');
% hold off;
% figure; imshow(x,[min(x(:)), max(x(:))]);
% hold on;
% plot(xp,yp,'bo');
% hold off;

% enter final values for xpeak and ypeak
if length(xpeakold) > 1 || length(xpeaknew) > 1 % peaks not unique
    xpeak = -1;
    ypeak = -1;
elseif sqrt((ypeaknew-ypeakold)^2 + (xpeaknew-xpeakold)^2) < 20
    xpeak = xpeakold;
    ypeak = ypeakold;
else
    xpeak = xpeaknew;
    ypeak = ypeaknew;
end

end

