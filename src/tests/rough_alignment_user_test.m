% test script for rough alignment.


% provide a cube of images. keep it small if you want it to run quickly.
% name it 'im'.

imnew = roughalign(im);

% this should display error metrics for the new and original cubes and some
% error statistics. 
% imnew is the new stack of aligned images. 