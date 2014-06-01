function [ xpeak, ypeak ] = detectpeaks( c, type )
%DETECTPEAKS Detects significant peaks of image in fourier domain.
%   

tempsize = ceil(max(size(c))/8);

if strcmpi(type, 'gaussian');
    y = normpdf(-tempsize:tempsize, 0, 5);
elseif strcmpi(type, 'exp');
    y = exppdf(0:tempsize, 5);
    y = [fliplr(y), y];
end
template = y'*y;

x = normxcorr2(template, c);
figure; imshowpair(c,x, 'montage');
[ypeak, xpeak] = find(x==max(x(:)));
ypeaknew = ypeak-tempsize;
xpeaknew = xpeak-tempsize;

[ypeak, xpeak] = find(c==max(c(:)));

if sqrt((xpeaknew-xpeak)^2 + (ypeaknew-ypeak)^2) > 20 || ...
        length(xpeak) > 1 || length(xpeaknew) > 1
    xpeak = -1;
    ypeak = -1;
end

end

