function [ ISAligned ] = constructalignment( IStack, Transforms )
%CONSTRUCTALIGNMENT Transforms image stack as instructed
%   [ IStackAligned ] = constructalignment( IStack, Transforms ) Takes in
%   stack of images, IStack, and a list of Transforms. Performs alignment
%   on all images in IStack.

ISAligned = IStack(:,:,1);
prevT = eye(3);
for i=1:(size(IStack, 3)-1)
    vals = values(Transforms, {localindices2key(i, i+1)});
    % performs affine transformation as specified by transform params
    prevT = updatetransform(IStack(:,:, i+1), vals{1}, prevT);
    ISAligned = affinetransform(IStack(:,:,i+1), ISAligned, prevT);
end
ISAligned = flip(ISAligned, 3);
end
