alignment
=========

Code for automated alignment of an image stack. Currently supports rigid affine alignment.

###Instructions
####Demo

####Usage

The function alignRAMONVol performs affine alignment on a RAMONVolume input. Transforms is an optional input that can either be the pairwise transforms for the RAMONVolume, or pairwise transforms for an entire data set.
unalignRAMONVol takes as input an already aligned RAMONVolume with its pairwise transforms, and returns the original unaligned image stack. 

The function read_api reads data using the CAJAL3D-API. 

  help alignRAMONVol
  help read_api

To test both, run the following in MATLAB:

  oo = OCP();
  oo.setImageToken('kasthuri11cc');
  RAMONOrig = read_api(oo, 20000, 20000, 5, 512, 512, 5, 1);
  [RAMONAligned, Transforms] = alignRAMONVol(RAMONOrig);

To unalign the aligned RAMONVolume:

  RAMONUnaligned = unalignRAMONVol(RAMONAligned, Transforms);

constructimgcubetransforms computes pairwise alignment for an entire data set (ex. kasthuri11cc). 

  help constructimgcubetransforms




NOTE: as always, make sure the required functions and dependencies are in your matlab path!

