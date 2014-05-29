function [ Transforms ] = constructtransforms( M )
%CONSTRUCTTRANSFORMS determines transform parameters to align pairwise
%images from image cube.

% initialize nested cell arrays
ids = cell(1, size(M,3)-1);
tforms = cell(1, size(M,3)-1);

% iterate through stack, compute transformations for rougha alignment.
for i=1:size(M,3)-1
    tform = xcorr2imgs(M(:,:,i), M(:,:,i+1));
    ids(i) = {[int2str(i),' ',int2str(i+1)]};
    tforms(i) = {tform};
end
Transforms = containers.Map(ids, tforms);

end

