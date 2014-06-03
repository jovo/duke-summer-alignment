function [ ypeak, xpeak ] = detectpeaks( oldC, tempsize, type )
%DETECTPEAKS Detects significant peaks of image in fourier domain.
%   [ xpeak, ypeak ] = detectpeaks( c, tempsize, type ) takes an image in
%   the fourier domain, c, and evaluates the peak. tempsize specifies the
%   distribution of the peak it should model. If program finds a potential
%   error in peak detection, will return -1 for all outputs;

% construct the distribution that c will correlate with
if strcmpi(type, 'gaussian');
    y = normpdf(-tempsize:tempsize, 0, 2);
elseif strcmpi(type, 'exp');
    y = exppdf(0:tempsize, 2);
    y = [fliplr(y), y];
end
template = y'*y;

% correlate and find new peaks
[ypeakold, xpeakold] = find(oldC==max(oldC(:)));
cpad = padarray(oldC, [tempsize, tempsize], 'symmetric');
newC = normxcorr2(template, cpad);
bounds = tempsize*2+1;
newC = newC(bounds:size(newC,1)-bounds, bounds:size(newC,2)-bounds);
[ypeaknew, xpeaknew] = find(newC==max(newC(:)));

% size(oldC)
% size(newC)
% figure; imshow(oldC,[min(oldC(:)), max(oldC(:))]);
% hold on;
% plot(xpeakold,ypeakold,'ro');
% hold off;
% figure; imshow(newC,[min(newC(:)), max(newC(:))]);
% hold on;
% plot(xpeaknew,ypeaknew,'bo');
% hold off;

% enter final values for xpeak and ypeak
if length(xpeaknew) > 1 && ...  % non-unique maxima
       sqrt((ypeaknew(1)-ypeaknew(2))^2 + (xpeaknew(1)-xpeaknew(2))^2) > 3
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

