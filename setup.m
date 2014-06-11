addpath(genpath('data'));
addpath(genpath('src'));

global minnonzeropercent scalethreshold peakclassifier;

% the the minimum value of the intersection of two images divided by the
% union of two images. This basically indicates the minimum amount of
% overlap acceptable for the alignment of two images. Any alignment with
% less than this percent overlap is rejected.
minnonzeropercent = 0.3;

% the maximum amount of scaling possible for one image to align with
% another. Any alignment with a scale greater than this threshold is
% rejected.
scalethreshold = 1.05;

% classifier for detecting peaks. If peakclassifier = -1, then don't use a
% classfier for peak detection.
peakclassifier = classifier;
% peakclassifier = -1;