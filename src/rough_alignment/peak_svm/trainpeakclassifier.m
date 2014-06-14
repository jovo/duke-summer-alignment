function [ svm ] = trainpeakclassifier( X, Y )
%TRAINPEAKCLASSFIER Trains a binary SVM classfier for peak detection
%   [ svm ] = trainpeakclassifier( X, Y ) X and Y are the input feature
%   vectors and labels, svm is the svm of class ClassificationSVM.

tic

% train and cross-validate SVM
model = fitcsvm(X, Y, 'Standardize', true, 'ClassNames', logical([0,1]));
svm = fitSVMPosterior(model);

toc

end
