function [ Transforms ] = constructtransforms( M )
%CONSTRUCTTRANSFORMS determines transform parameters to align pairwise
%images from image cube.

% initialize nested cell arrays
ids = cell(1, size(M,3)-1);
tforms = cell(1, size(M,3)-1);

% stores variables as matfile to save memory
filename = strcat(lower(randseq(16, 'Alphabet','amino')),'.mat');
save(filename,'M', 'tforms', 'ids', '-v7.3');
data = matfile(filename, 'Writable', true);
looplength = size(M, 3) - 1;
clear ids tforms M;

% iterate through stack, compute transformations for rough alignment.
for i=1:looplength
    img1 = data.M(:,:,i);
    img2 = data.M(:,:,i+1);
    tform = xcorr2imgs(img1, img2, '', 1);
    data.ids(1,i) = {[int2str(i),' ',int2str(i+1)]};
    data.tforms(1,i) = {tform};
end
Transforms = containers.Map(data.ids, data.tforms);

delete(filename);
end

