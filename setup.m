addpath(genpath('data'));
addpath(genpath('src'));

global minnonzeropercent peakclassifier errormeasure minpercenterrorimprovement scalealign;

% the the minimum value of the intersection of two images divided by the
% union of two images. This basically indicates the minimum amount of
% overlap acceptable for the alignment of two images. Any alignment with
% less than this percent overlap is rejected.
minnonzeropercent = 0.2;

% classifier for detecting peaks. If peakclassifier is unassigned, then
% don't use a classfier for peak detection.
peakclassifier = classifier;

% specify the error metrics. Default is Mean squared error (mse). Other
% available error metrics include peak signal to noise ratio (psnr) and
% pixel difference (pxdiff)
errormeasure = 'mse';

% the minimum acceptable value for the amount of error improvement as a
% result of alignment. Any error improvement less than this value will
% undergo further optimization by utilizing images surrounding the image
% pair of interest.
minpercenterrorimprovement = 0.1;

% scaling during transformation calculations to for greater efficiency
scalealign = 0.5;
