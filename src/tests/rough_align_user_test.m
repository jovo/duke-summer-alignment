%% USER TEST SCRIPT FOR ROUGH_ALIGN.M
% Read the instructions on this script. Then run this script.

% 1) Name the image cube you wish to run with rough_align.m to 'im'
% 2) run roughalign(im);
imnew = roughalign(im);
% 3) wait. depending on cube size, this may take a while. 
% 4) once done running, error metrics showing the difference in MSE is
% displayed for each adjacent pair. An error report summary for original
% and aligned cubes should also be displayed.
% 5) the variable for aligned cube is 'imnew'