function [ IStackAligned ] = constructalignment( IStack, Transforms )
%CONSTRUCTALIGNMENT Transforms image stack as instructed
%   [ IStackAligned ] = constructalignment( IStack, Transforms ) Takes in
%   stack of images, IStack, and a list of Transforms. Performs alignment
%   on all images in IStack.

Ids = 1:size(IStack, 3);
IStackAligned = RLHelper(Ids, IStack);

% recursive helper that does the work.
function [ istacknew ] = RLHelper( ids, istack )
switch size(istack, 3)
    case 0  % image is nil. do nothing
    case 1  % only one image. no need to align.
        istacknew = istack;
    otherwise
        partit = floor(size(istack,3)/2);   % index that partitions stack
        key = {[int2str(ids(partit)), ' ', int2str(ids(partit+1))]};
        vals = values(Transforms, key);
        % performs affine transformation as specified by transform params
        aligned = affinetransform(istack(:,:,1:partit),istack(:,:,partit+1:end),vals{1});
        % recurse on both partitions
        a1n = RLHelper(ids(1:partit), aligned(:,:,1:partit));
        a2n = RLHelper(ids(partit+1:end), aligned(:,:,partit+1:end));
        % pad either/both aligned partitions to same size and concatenate
        ymax = max(size(a1n,1), size(a2n,1));
        xmax = max(size(a1n,2), size(a2n,2));
        a1n = padarray(a1n, [ymax-size(a1n,1), xmax-size(a1n,2), 0], 0, 'post');
        a2n = padarray(a2n, [ymax-size(a2n,1), xmax-size(a2n,2), 0], 0, 'post');
        istacknew = cat(3, a1n, a2n);
end
end

end
