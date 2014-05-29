function [ MergedStack ] = affinetransform( templateStack, AStack, tforms )
%AFFINETRANSFORM Performs translation, rotation, scaling to align images
%   [ Merged, MergedStack ] = affinetransform( template, A, templateStack, AStack, tforms )
%   template and A are the two images to be aligned templateStack and
%   AStack are the stacks associated with template and A. The same
%   transformations on template

% retrieve transformations from tforms
TranslateY = tforms(1);
TranslateX = tforms(2);
THETA = tforms(3);
SCALE = tforms(4);

% Perform translation, rotation, scaling transformations to images
TStack = imrotate(imresize(templateStack, 1/SCALE), THETA, 'nearest', 'crop');
depthA = size(AStack, 3);
depthT = size(TStack, 3);
AStacky = size(AStack, 1);
AStackx = size(AStack, 2);
TStacky = size(TStack, 1);
TStackx = size(TStack, 2);
newstack_y = max(AStacky, max(abs(TranslateY) + TStacky, abs(TranslateY) + AStacky));
newstack_x = max(AStackx, max(abs(TranslateX) + TStackx, abs(TranslateX) + AStackx));
AStack_new = uint8(zeros(newstack_y, newstack_x, depthA));
TStack_new = uint8(zeros(newstack_y, newstack_x, depthT));

if TranslateY > 0
    Ayrangestack = 1:AStacky;
    Tyrangestack = (1:TStacky) + TranslateY;
    if TranslateX > 0
        Axrangestack = 1:AStackx;
        Txrangestack = (1:TStackx) + TranslateX;
    else
        Axrangestack = (1:AStackx) + abs(TranslateX);
        Txrangestack = 1:TStackx;
    end
else
    Ayrangestack = (1:AStacky) + abs(TranslateY);
    Tyrangestack = 1:TStacky;
    if TranslateX > 0
        Axrangestack = 1:AStackx;
        Txrangestack = (1:TStackx) + TranslateX;
    else
        Axrangestack = (1:AStackx) + abs(TranslateX);
        Txrangestack = 1:TStackx;
    end
end

AStack_new(Ayrangestack, Axrangestack, :) = AStack;
TStack_new(Tyrangestack, Txrangestack, :) = TStack;

MergedStack = cat(3, TStack_new, AStack_new);

end

