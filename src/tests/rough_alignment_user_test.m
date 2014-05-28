% test script for rough alignment.


% provide a cube of images. keep it small if you want it to run quickly.
% name it 'im'.

imnew = roughalign(im);
% show diff for each pair.
for i=1:size(imnew, 3)-1
    figure; imshowpair(imnew(:,:,i), imnew(:,:,i+1), 'diff');
end

% this should display error metrics for the new and original cubes and some
% error statistics. 
% imnew is the new stack of aligned images.
% the diff between each pair should be outputted.