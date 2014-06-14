function [ ypeak, xpeak ] = detectpeaksvm( c, classifier )
%DETECTPEAKSVM Binary classification of peaks with a Support Vector Machine
%   [ ypeak, xpeak ] = detectpeaksvm( c, classifier )

% divide image into 9 subsections.
ycrop = floor(size(c,1)/3);
xcrop = floor(size(c,2)/3);
ccropped = mat2cell(c, [ycrop, ycrop, size(c,1)-ycrop*2], [xcrop, xcrop, size(c,2)-xcrop*2]);

% iterate through subsections, find the max in each
ccropped = ccropped(:);
maxIndices = NaN(length(ccropped), 3);
for i=1:length(ccropped)
    curimage = ccropped{i};
    cmax = max(curimage(:));
    [ypeaks, xpeaks] = find(curimage==cmax);
    maxIndices(i,:) = [cmax, ypeaks(1), xpeaks(1)];
end

% sort the peaks by intensity (first column)
[~,I] = sort(maxIndices(:,1));
maxIndices = maxIndices(I,:);

% iterate through each possible peak, and classify
for i=1:size(maxIndices,1);
    yptemp = maxIndices(i,2);
    xptemp = maxIndices(i,3);
    feature = getpeakfeatures(c, yptemp, xptemp);
    [label,~] = predict(classifier, feature);
    if label
        ypeak = yptemp;
        xpeak = xptemp;
        return;
    end
end
% if classfier fails to find peak, output -1.
if ~exist('ypeak', 'var') || ~exist('xpeak', 'var')
    ypeak = -1;
    xpeak = -1;
end

end

