function [ MergedStack, templatetforms ] = affinetransform( templateStack, AStack, tforms, prevtforms )
%AFFINETRANSFORM Performs translation, rotation, scaling to align images
%   [ MergedStack, templatetforms ] = affinetransform( templateStack, AStack, tforms, prevtforms )
%   only templateStack gets rotated and/or scaled, and recorded in
%   templatetforms. If templateStack gets shifted in positive directions,
%   then that direction is recorded in templateForms. If templateStack gets
%   shifted in negative directions, don't record transformations.

%% using transformation parameters
% retrieve transformations from tforms
tforms = tforms{1};
TranslateY = tforms(1) + prevtforms(1);
TranslateX = tforms(2) + prevtforms(2);
THETA = tforms(3) + prevtforms(3);
SCALE = tforms(4) * prevtforms(4);

templatetforms = zeros(1,4);
% Perform translation, rotation, scaling transformations to images
TStack = imrotate(imresize(templateStack, 1/SCALE), THETA, 'nearest', 'crop');
templatetforms(3:4) = [THETA, SCALE];
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
    templatetforms(1) = TranslateY;
    if TranslateX > 0
        Axrangestack = 1:AStackx;
        Txrangestack = (1:TStackx) + TranslateX;
        newstack_x = max(AStackx, abs(TranslateX) + TStackx);
        templatetforms(2) = TranslateX;
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
        templatetforms(2) = TranslateX;
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

MergedStack = cat(3, TStack_new, AStack_new);

%% using a transformation matrix. BUGGY atm.
% tforms = tforms{2};
% TStack_new = imwarp(templateStack, tforms);
% yrange = max(size(TStack_new, 1), size(AStack, 1));
% xrange = max(size(TStack_new, 2), size(AStack, 2));
% TStack_new = padarray(TStack_new, [yrange-size(TStack_new,1), xrange-size(TStack_new,2)], 0, 'post');
% AStack = padarray(AStack, [yrange-size(AStack,1), xrange-size(AStack,2)], 0, 'post');
% MergedStack = cat(3, TStack_new, AStack);

end

