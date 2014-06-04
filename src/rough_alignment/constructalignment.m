function [ IStackAligned ] = constructalignment( IStack, Transforms )
%CONSTRUCTALIGNMENT Transforms image stack as instructed
%   [ IStackAligned ] = constructalignment( IStack, Transforms ) Takes in
%   stack of images, IStack, and a list of Transforms. Performs alignment
%   on all images in IStack.

IStackAligned = IStack(:,:,1);
prevtransform = [0,0,0,1];
for i=1:size(IStack, 3)-1
    key = {[int2str(i), ' ', int2str(i+1)]};
    vals = values(Transforms, key);
    % performs affine transformation as specified by transform params
    [IStackAligned, prevtransform] = affinetransform(IStack(:,:,i+1),IStackAligned,vals{1}, prevtransform);
end
IStackAligned = flip(IStackAligned,3);
end
