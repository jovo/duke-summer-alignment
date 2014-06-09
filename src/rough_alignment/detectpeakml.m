function [ ypeak, xpeak ] = detectpeakml( c, classifier )
%DETECTPEAKSVM Binary classification of peaks with a Support Vector Machine
%   [ ypeak, xpeak ] = detectpeakml( c, classifier )

N = 10;     % indicate # of possible peak points to classify
csorted = sort(c(:));   % sort the image by intensity
% interate throgh each possible peak, and classify
for i=1:N
    [yptemparray, xptemparray] = find(c==csorted(i));
    yptemp = yptemparray(1);
    xptemp = xptemparray(1);
    feature = getpeakfeatures(c, yptemp, xptemp);
    ScoreSVMModel = fitSVMPosterior(classifier);
    [label, ~] = predict(ScoreSVMModel, feature);
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

