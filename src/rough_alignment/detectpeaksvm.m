function [ ypeak, xpeak ] = detectpeaksvm( c, classifier )
%DETECTPEAKSVM Binary classification of peaks with a Support Vector Machine
%   [ ypeak, xpeak ] = detectpeaksvm( c, classifier )

% divide image into 9 subsections.
ycrop = floor(size(c,1)/3);
xcrop = floor(size(c,2)/3);
ccropped = mat2cell(c, [ycrop, ycrop, size(c,1)-ycrop*2], [xcrop, xcrop, size(c,2)-xcrop*2]);

% iterate through subsections, find the max in each relative to whole img
maxIndices = NaN(size(ccropped,1)*size(ccropped,2), 3);
k = 1;
ystart = 0;
for i=1:size(ccropped, 1)
    xstart = 0;
    for j=1:size(ccropped, 2)
        curimage = ccropped{i,j};
        cmax = max(curimage(:));
        [ypeaks, xpeaks] = find(curimage==cmax);
        maxIndices(k,:) = [cmax, ystart + ypeaks(1), xstart + xpeaks(1)];
        k = k + 1;
        xstart = xstart + xcrop;
    end
    ystart = ystart + ycrop;
end

% sort the peaks by intensity (first column)
[~,I] = sort(maxIndices(:,1), 'descend');
maxIndices = maxIndices(I,:);

% iterate through each possible peak, and classify
for i=1:size(maxIndices,1);
    yptemp = maxIndices(i,2);
    xptemp = maxIndices(i,3);
    feature = getpeakfeatures(c, yptemp, xptemp);
    if sum(isnan(feature)) > 0
        disp('oh no');
        feature
    end
    if strcmpi(class(classifier), 'ClassificationSVM')
        [label,~] = predict(classifier, feature);
    else
        label = svmclassify(classifier, feature);
    end
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

