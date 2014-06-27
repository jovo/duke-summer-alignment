function [ RAMONOrig ] = unalignRAMONVol( RAMONAligned, Transforms )

% convert from global to local transforms
localinvtforms = global2localmap(Transforms);

% change map to inverse transforms
k = keys(localinvtforms);
for i=1:length(k)
    curval = values(localinvtforms, k(i));
    localinvtforms(k{i}) = inverse(curval);
end

% unalign already aligned data using inverse transforms
[ unaligned ] = constructalignment(RAMONAligned.data, localinvtforms);

% store unaligned data as 
RAMONOrig = RAMONAligned;
RAMONOrig.setCutout(unaligned);

end
