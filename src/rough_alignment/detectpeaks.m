function [ xpeaknew, ypeaknew ] = detectpeaks( c, type )
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
[~, xpeakold] = find(c==max(c(:)));
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

% indicates a problem with peak detection and returns -1.
if length(xpeakold) > 1 || length(xpeaknew) > 1
    xpeaknew = -1;
    ypeaknew = -1;
end

end

