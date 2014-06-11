function [ ypeak, xpeak ] = detectpeakml( c, classifier )
%DETECTPEAKSVM Binary classification of peaks with a Support Vector Machine
%   [ ypeak, xpeak ] = detectpeakml( c, classifier )

N = 5;     % indicate # of possible peak points to classify
csorted = sort(c(:), 1, 'descend');   % sort the image by intensity
% iterate through each possible peak, and classify
for i=1:N
    [yptemparray, xptemparray] = find(c==csorted(i));
    yptemp = yptemparray(1);
    xptemp = xptemparray(1);
    feature = getpeakfeatures(c, yptemp, xptemp);
    [label,~] = predict(classifier, feature);
    if label
        ypeak = yptemp;
        xpeak = xptemp;
        break;
    end
end
% if classfier fails to find peak, output -1.
if ~exist('ypeak', 'var') || ~exist('xpeak', 'var')
    ypeak = -1;
    xpeak = -1;
end

end
