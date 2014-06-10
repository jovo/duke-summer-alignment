function [ classifier ] = trainpeakclassifier( IStack )
%TRAINPEAKCLASSFIER Trains a binary SVM classfier for peak detection
%   Detailed explanation goes here

% generate ground truth
[X, Y] = generategroundtruth(IStack, 1, size(IStack,1), size(IStack,2));
% train SVM
classifier = fitcsvm(X, Y, 'ClassNames', logical([0,1]));
% cross-validate SVM


end
