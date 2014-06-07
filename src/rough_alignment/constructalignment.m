function [ ISAligned ] = constructalignment( IStack, Transforms )
%CONSTRUCTALIGNMENT Transforms image stack as instructed
%   [ IStackAligned ] = constructalignment( IStack, Transforms ) Takes in
%   stack of images, IStack, and a list of Transforms. Performs alignment
%   on all images in IStack.

ISAligned = IStack(:,:,1);
params = [0,0,0,1,0];
prevT = {params; affine2d(params2matrix(params))};
for i=1:(size(IStack, 3)-1)
    vals = values(Transforms, {indices2key(i, i+1)});
    % performs affine transformation as specified by transform params
    [ISAligned, prevT] = affinetransform(IStack(:,:,i+1), ISAligned, vals{1}, prevT);
end
ISAligned = flip(ISAligned, 3);
end