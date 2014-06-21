alignment
=========

Code for automated alignment of an image stack. Currently supports rigid affine alignment.

###Instructions
####Demo
Quick demo. This currently requires a working CAJAL3D-API in your matlab path. If you wish to use your own data, modify rough\_align\_user\_test.m as appropriate.

1. add the entire folder to MATLAB path. If you wish to use the API, add that directory to path as well.

2. open rough\_align\_user\_test.m in the /src/tests/ directory. Read the instructions on the file, then run the script in matlab. 

####Usage
The function roughalign performs all the alignment on an image stack. To read the documentation on roughalign, find it in src/rough\_alignment or

	help roughalign

To align a stack of images, input the image stack into roughalign. Suppose the variable name of your image stack is IStack. Then

	[tforms, aligned] = roughalign(IStack, 'align', 0.5);

does several things; adding 'align' as the second parameter also completely aligns the image stack in addition to computing pairwise transforms. The aligned images are saved to the output variable aligned. tforms is the containers.Map containing all the pairwise transformations. Specifying 0.5 means the images are scaled by that much before determining transformations. The outputted tranformations still apply to the original inputs though. Not specifying the third parameter implies a scaling of 1.

To use an svm for improved results in alignment, and/or customize your own alignment parameters, see setup.m for more info. Then

    config = setupconfigvars();
    [tforms, aligned] = roughalign(IStack, 'align', 0.5, config);

NOTE: as always, make sure the required functions and dependencies are in your matlab path!

