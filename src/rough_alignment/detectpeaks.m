function [ ypeak, xpeak ] = detectpeaks( c, type )
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
cpad = padarray(c, [tempsize*2, tempsize*2], 'symmetric');
x = normxcorr2(template, cpad);
x = x(tempsize*3+1:size(x,1)-tempsize*3, tempsize*3+1:size(x,2)-tempsize*3);
[ypeaknew, xpeaknew] = find(x==max(x(:)));

% figure; imshow(c,[min(c(:)), max(c(:))]);
% hold on;
% plot(xpeakold,ypeakold,'ro');
% hold off;
% figure; imshow(x,[min(x(:)), max(x(:))]);
% hold on;
% plot(xpeaknew,ypeaknew,'bo');
% hold off;

% enter final values for xpeak and ypeak
if length(xpeaknew) > 1 % peaks not unique
    xpeak = -1;
    ypeak = -1;
elseif sqrt((ypeaknew(1)-ypeakold(1))^2 + (xpeaknew(1)-xpeakold(1))^2) < 20
    xpeak = xpeakold(1);
    ypeak = ypeakold(1);
else
    xpeak = xpeaknew(1);
    ypeak = ypeaknew(1);
end

end

