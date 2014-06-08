function [ MergedStack, updatedtform ] = affinetransform( templateStack, AStack, curtform, prevtform )
%AFFINETRANSFORM Performs translation, rotation, scaling to align images
%   [ MergedStack, templatetforms ] = affinetransform( templateStack, AStack, tforms, prevtforms )
%   only templateStack gets rotated and/or scaled, and recorded in
%   templatetforms. If templateStack gets shifted in positive directions,
%   then that direction is recorded in templateForms. If templateStack gets
%   shifted in negative directions, don't record transformations.

%% using transformation parameters
% retrieve transformations from tforms

if nargin < 4
    prevtform = eye(3);
end
newtform = curtform*prevtform;
prevtparam = matrix2params(prevtform);
newtparam = matrix2params(newtform);
TranslateYunrounded = newtparam(1);
TranslateXunrounded = newtparam(2);
TranslateY = round(TranslateYunrounded);
TranslateX = round(TranslateXunrounded);
THETA = newtparam(3);
SCALE = newtparam(4);

updatedtparam = zeros(1,4);
updatedtparam(3:4) = newtparam(3:4);
% Perform translation, rotation, scaling transformations to images
TStack = imrotate(imresize(templateStack, 1/SCALE), THETA, 'nearest', 'crop');
depthA = size(AStack, 3);
depthT = size(TStack, 3);
AStacky = size(AStack, 1);
AStackx = size(AStack, 2);
TStacky = size(TStack, 1);
TStackx = size(TStack, 2);

if TranslateY > 0
    Ayrangestack = 1:AStacky;
    Tyrangestack = (1:TStacky) + TranslateY;
    newstack_y = max(AStacky, abs(TranslateY) + TStacky);
    updatedtparam(1) = TranslateYunrounded;
    if TranslateX > 0
        Axrangestack = 1:AStackx;
        Txrangestack = (1:TStackx) + TranslateX;
        newstack_x = max(AStackx, abs(TranslateX) + TStackx);
        updatedtparam(2) = TranslateXunrounded;
    else
        Axrangestack = (1:AStackx) + abs(TranslateX);
        Txrangestack = 1:TStackx;
        newstack_x = max(TStackx, abs(TranslateX) + AStackx);
    end
else
    Ayrangestack = (1:AStacky) + abs(TranslateY);
    Tyrangestack = 1:TStacky;
    newstack_y = max(TStacky, abs(TranslateY) + AStacky);
    if TranslateX > 0
        Axrangestack = 1:AStackx;
        Txrangestack = (1:TStackx) + TranslateX;
        newstack_x = max(AStackx, abs(TranslateX) + TStackx);
        updatedtparam(2) = TranslateXunrounded;
    else
        Axrangestack = (1:AStackx) + abs(TranslateX);
        Txrangestack = 1:TStackx;
        newstack_x = max(TStackx, abs(TranslateX) + AStackx);
    end
end
AStack_new = uint8(zeros(newstack_y, newstack_x, depthA));
TStack_new = uint8(zeros(newstack_y, newstack_x, depthT));

AStack_new(Ayrangestack, Axrangestack, :) = AStack;
TStack_new(Tyrangestack, Txrangestack, :) = TStack;

updatedtform = params2matrix(updatedtparam);
MergedStack = cat(3, TStack_new, AStack_new);

%% using a transformation matrix. BUGGY atm.
% updatedmatrix = curmatrix*prematrix;
% TStack_new = imwarp(templateStack, affine2d(updatedmatrix));
% yrange = max(size(TStack_new, 1), size(AStack, 1));
% xrange = max(size(TStack_new, 2), size(AStack, 2));
% TStack_new = padarray(TStack_new, [yrange-size(TStack_new,1), xrange-size(TStack_new,2)], 0, 'post');
% AStack = padarray(AStack, [yrange-size(AStack,1), xrange-size(AStack,2)], 0, 'post');
% MergedStack = cat(3, TStack_new, AStack);

end
