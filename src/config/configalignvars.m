function [ config ] = configalignvars
%CONFIGALIGNVARS outputs variables necessary for alignment in a structure
%that is later called by alignment functions.

config = struct;

% load svm
svm = load('data/svm/svm1.mat');

% the the minimum value of the intersection of two images divided by the
% union of two images. This basically indicates the minimum amount of
% overlap acceptable for the alignment of two images. Any alignment with
% less than this percent overlap is rejected.
config.minnonzeropercent = 0.2;

% classifier for detecting peaks. If classify is true (1), then alignment
% program will attempt to use peakclassifier. Otherwise, simple max-picking
% will determine peaks.
config.classify = 1;
config.peakclassifier = svm.classifier;

% specify the error metrics. Default is Mean squared error (mse). Other
% available error metrics include peak signal to noise ratio (psnr) and
% pixel difference (pxdiff)
config.errormeasure = 'mse';

% the minimum acceptable value for the amount of error improvement as a
% result of alignment. Any error improvement less than this value will
% undergo further optimization by utilizing images surrounding the image
% pair of interest.
config.minpercenterrorimprovement = 0.1;

% downsampling before computing alignment on image stack. The
% transformations are then scaled back to the original sizes.
config.downsample = 0.5;

% if true (1), then messages that appear during alignment will be
% suppressed (namely warnings of potential failed alignments). Change to
% false (0) to receive the warnings. However, this can often be an
% annoyance for large data sets, and so the default is set to (1) for ones
% sanity.
config.suppressmessages = 1;

end
