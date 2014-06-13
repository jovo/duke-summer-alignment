function [ ypeak1, xpeak1, ypeak2, xpeak2 ] = detectpeakcmp( c1, c2, img1t, img1a, img2t, img2a, peakthres )
%DETECTPEAKTHRESH Detect peaks by comparison and thresholding
%   Detailed explanation goes here

[~, flag1] = errormetrics(cat(3, img1t, img1a), 'pxdiff');
[~, flag2] = errormetrics(cat(3, img2t, img2a), 'pxdiff');

if ~exist('peakthres', 'var')
    peakthres = 0.01;
end
c1max = max(c1(:));
c2max = max(c2(:));
if c1max - c2max > peakthres && ~flag1
    [ypeak1, xpeak1] = find(c1==c1max);
else
    ypeak1 = -1;
    xpeak1 = -1;
end
if c2max -c1max > peakthres && ~flag2
    [ypeak2, xpeak2] = find(c2==c2max);
else
    ypeak2 = -1;
    xpeak2 = -1;
end

end

