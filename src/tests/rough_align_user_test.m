%% USER TEST SCRIPT FOR ROUGH_ALIGN.M
% Read the instructions on this script. Then run this script.

% 0) To download an example 1024 by 1024 by 100 cube from the API, run
% read_api. If you don't wish to use the API, comment out the below two
% lines. If there is a specific cube you wish to use, modify the read_api
% code accordingly.
cutout = read_api;
im = cutout.data;
% 1) Name the image cube you wish to run with rough_align.m to 'im'
% 2) the scale is set to 0.5 right now. This means that each image is
% scaled by 0.5 before computing the transforms. This improves the running
% time especially for big images. A few tests show this minimally impacts
% the alignment performance on 1024 by 1024 images.
scale = 0.5;
% 3) run roughalign(im);
[transforms, merged] = roughalign(im, 1, scale);
% 4) wait. depending on cube size, this may take a while.
% 5) once done running, error metrics showing the difference in MSE is
% displayed for each adjacent pair. An error report summary for original
% and aligned cubes should also be displayed.
% 6) the variable for aligned cube is 'merged'. The variable 'transforms'
% has the table of transforms in a matlab map data structure.
% 7) run the gui to visualize transformations.
align_gui
% 7.1) enter the variable name of the image stack you wish to visualize,
% probably 'merged' in this case.
