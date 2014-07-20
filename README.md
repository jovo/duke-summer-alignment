alignment
=========

Code for automated alignment of an image stack. Currently supports rigid affine alignment.

###Instructions

####Demo

The script alignmenttests.m downloads a cube from the API. It then performs large rotations and translations before aligning and unaligning the cube. Open the script to learn more about it, and:

    alignmenttests;
    image(newRAMON);
    image(RAMONAligned)
    image(newRAMONOrig)

newRAMON and newRAMONorig should be the same. RAMONAligned is the aligned version of newRAMON.

####Usage

The first step in using this program is to open configalignvars and configapivars in src/config/. configalignvars contains the configuration settings for pairwise and global alignment. configapivars has the settings for retrieving data from CAJAL3D-API when needing to align an entire data set (ex. kasthuri11cc). Open both files to change the settings. These functions will be called automatically when needed.

The function alignRAMONVol performs affine alignment on a RAMONVolume input. Transforms is an optional input that can either be the pairwise transforms for the RAMONVolume or pairwise transforms for an entire data set.
unalignRAMONVol takes as input an already aligned RAMONVolume with its pairwise transforms and returns the original unaligned image stack.

The function read_api reads data using the CAJAL3D-API. 

    help alignRAMONVol
    help read_api

To test both, run the following in MATLAB:

    oo = OCP();
    oo.setImageToken('kasthuri11cc');
    RAMONOrig = read_api(oo, 512, 512, 5, 3000, 5000, 400, 1);
    [RAMONAligned, Transforms] = alignRAMONVol(RAMONOrig);

To unalign the aligned RAMONVolume:

    RAMONUnaligned = unalignRAMONVol(RAMONAligned, Transforms);

constructimgcubetransforms computes pairwise alignment for large data sets by splitting the work into small sub-cubes (ex. kasthuri11cc).

    help constructimgcubetransforms

To test this function, run the following. The configurations for this function are in configapivars. NOTE: this may take a long time and/or run out of memory depending on your machine. There is also the option of using parallel computing to speed up the alignment process. See configapivars to change that option. Parallel computing should be on by default.

    Transforms = constructimgcubetransforms

Constructimgcubealignment aligns a specified sub-cube of the entire dataset using the transforms generated by constructimgcubetransforms. The output is a RAMONVolume of the size specified in the inputs. 

    help constructimgcubealignment

To test this function, run the following. The first input is the output of constructimgcubetransforms.

    cutout = constructimgcubealignment(Transforms, 512, 512, 5, 3000, 5000, 400);

The output of constructimgcubetransforms can also be used by alignRAMONVol. The benefit is that the pairwise alignment parameters are already stored as output from constructimgcubetransforms. Thus, the most memory and time-intensive process is already precomputed. All that is required is to read the pairwise transformation parameters and construct the overall alignment.

    RAMONAligned2 = alignRAMONVol(cutout);


NOTE: As always, make sure the required functions and dependencies are in your MATLAB path!

