function [ svm ] = trainpeakclassifier( X, Y )
%TRAINPEAKCLASSFIER Trains a binary SVM classfier for peak detection
%   [ svm ] = trainpeakclassifier( X, Y ) X and Y are the input feature
%   vectors and labels, svm is the trained svm object. Can either be a
%   struct or ClassificationSVM object.

tic

% train SVM
svm = svmtrain(X, Y);

% train binary SVM (>=2014b)
% SVMModel = fitcsvm(X, Y, 'Standardize', true, 'ClassNames', logical([0,1]));
% svm = fitSVMPosterior(SVMModel);

toc

end
