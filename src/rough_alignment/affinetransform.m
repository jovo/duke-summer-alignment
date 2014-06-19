function [ MergedStack, updatedtform ] = affinetransform( templateStack, AStack, curtform )
%AFFINETRANSFORM Performs translation and rotation to align images
%   [ MergedStack, templatetforms ] = affinetransform( templateStack, AStack, tforms )
%   only templateStack gets rotated and/or scaled, and recorded in
%   templatetforms. If templateStack gets shifted in positive directions,
%   then that direction is recorded in templateForms. If templateStack gets
%   shifted in negative directions, don't record transformations.

% compute the actual transformation to apply.
newtparam = matrix2params(curtform);
TranslateYunrounded = newtparam(1);
TranslateXunrounded = newtparam(2);
TranslateY = round(TranslateYunrounded);
TranslateX = round(TranslateXunrounded);
THETA = newtparam(3);

% save the actual transformation to updatedtform
updatedtparam = zeros(1, 3);
updatedtparam(3) = newtparam(3);
if TranslateY > 0
    updatedtparam(1) = TranslateYunrounded;
end
if TranslateX > 0
    updatedtparam(2) = TranslateXunrounded;
end
updatedtform = params2matrix(updatedtparam);

% Perform translation, rotation, scaling transformations to images
TStack = imrotate(templateStack, THETA, 'nearest', 'crop');
clear templateStack;
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
    if TranslateX > 0
        Axrangestack = 1:AStackx;
        Txrangestack = (1:TStackx) + TranslateX;
        newstack_x = max(AStackx, abs(TranslateX) + TStackx);
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
    else
        Axrangestack = (1:AStackx) + abs(TranslateX);
        Txrangestack = 1:TStackx;
        newstack_x = max(TStackx, abs(TranslateX) + AStackx);
    end
end
AStack_new = zeros(newstack_y, newstack_x, depthA, 'uint8');
TStack_new = zeros(newstack_y, newstack_x, depthT, 'uint8');

AStack_new(Ayrangestack, Axrangestack, :) = AStack;
TStack_new(Tyrangestack, Txrangestack, :) = TStack;

MergedStack = cat(3, TStack_new, AStack_new);

end
