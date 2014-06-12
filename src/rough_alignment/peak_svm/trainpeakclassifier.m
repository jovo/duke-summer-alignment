function [ SVMModel ] = trainpeakclassifier( X, Y )
%TRAINPEAKCLASSFIER Trains a binary SVM classfier for peak detection
%   Detailed explanation goes here

% train and cross-validate SVM
c = cvpartition(size(Y,1),'KFold',10);
minfn = @(z)kfoldLoss(fitcsvm(X, Y, 'CVPartition', c, 'BoxConstraint', ...
    exp(z(2)), 'KernelScale', exp(z(1)), 'ClassNames',logical([0,1])));
opts = optimset('TolX',5e-4,'TolFun',5e-4);
m = 20;
fval = zeros(m,1);
z = zeros(m,2);
for j = 1:m;
    [searchmin, fval(j)] = fminsearch(minfn, randn(2,1), opts);
    z(j,:) = exp(searchmin);
end

z = z(fval==min(fval),:);

classifier = fitcsvm(X, Y, 'KernelScale', z(1), 'BoxConstraint', z(2), 'ClassNames',logical([0,1]));
SVMModel = fitSVMPosterior(classifier);

end
