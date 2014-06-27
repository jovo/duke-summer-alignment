function [ RAMONOrig ] = unalignRAMONVol( RAMONAligned, Transforms )
%UNALIGNRAMONVOL Undo alignRAMONVol
% RAMONAligned is the aligned RAMONVolume, Transforms is a containers.Map
% object of the transforms that aligned RAMONAligned. RAMONOrig is the
% original RAMONVolume.

% convert from global to local transforms
localinvtforms = global2localmap(Transforms);

% change map to inverse transforms
k = keys(localinvtforms);
for i=1:length(k)
    curval = values(localinvtforms, k(i));
    localinvtforms(k{i}) = inv(curval{1});
end

% unalign already aligned data using inverse transforms
[ unaligned ] = constructalignment(RAMONAligned.data, localinvtforms);

% store unaligned data as 
RAMONOrig = RAMONAligned.clone();
RAMONOrig.setCutout(unaligned);

end
