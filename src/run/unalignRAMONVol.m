function [ RAMONOrig ] = unalignRAMONVol( RAMONAligned, Transforms )
%UNALIGNRAMONVOL Undo alignRAMONVol
% RAMONAligned is the aligned RAMONVolume, Transforms is a containers.Map
% object of the transforms that aligned RAMONAligned. RAMONOrig is the
% original RAMONVolume.

tic

% convert from global to local transforms
Transforms.pairwise = global2localmap(Transforms.pairwise);
Transforms.global = global2localmap(Transforms.global);

% unalign already aligned data using inverse transforms
inverse = 1;
[ unaligned ] = constructalignment(RAMONAligned.data, Transforms, inverse);

% store unaligned data as 
RAMONOrig = RAMONAligned.clone();
RAMONOrig.setCutout(unaligned);

toc

end
