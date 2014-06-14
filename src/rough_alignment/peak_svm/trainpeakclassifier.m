function [ svm ] = trainpeakclassifier( X, Y )
%TRAINPEAKCLASSFIER Trains a binary SVM classfier for peak detection
%   Detailed explanation goes here

tic

% train and cross-validate SVM
SVMModel = fitcsvm(X, Y, 'Standardize', true, 'ClassNames', logical([0,1]));
CSVMModel = crossval(SVMModel);
svm = fitSVMPosterior(CSVMModel);

toc

end
