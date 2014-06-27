function [ RAMONAligned, TransformsNew ] = alignRAMONVol( RAMONOrig, Transforms )
%ALIGNRAMONVOL Aligns RAMONVolumes
%   [ RAMONAligned, TransformsNew ] = alignRAMONVol( RAMONOrig, Transforms )
%   RAMONOrig is the unaligned image stack, Transforms is an optional
%   argument. Transforms can either be a structure outputted from
%   constructimgcubetransforms that contains the containers.Map or the
%   transform map themselves. If there is no Transforms parameter, then it
%   calculates the transforms and outputs them in a containers.Map object
%   TransformsNew. RAMONAligned is the aligned RAMONOrig.

% validate inputs
narginchk(1,2);

% retrieve data from RAMONVolume
resolution = RAMONOrig.resolution;
xyz = RAMONOrig.xyzOffset;
xoffset = xyz(1);
yoffset = xyz(2);
zoffset = xyz(3);
[ ysubsize, xsubsize, zsubsize ] = size(RAMONOrig.data);

% compute alignment with/without existing transforms
if nargin == 1

    % retrieve config variables for alignment
    alignconfig = configalignvars();
    % compute alignment transforms and align image cube
    [ temptforms, aligned ] = roughalign(RAMONOrig.data, 'align', alignconfig);
    % convert from local key back to global key
    TransformsNew = local2globalmap( ...
                                        temptforms, ...
                                        resolution, ...
                                        xoffset, ...
                                        yoffset, ...
                                        zoffset, ...
                                        xsubsize, ...
                                        ysubsize ...
                                    );

elseif nargin == 2

    if isa(Transforms, 'struct')
        aligned = constructimgcubealignment(    Transforms, ...
                                                xsubsize, ...
                                                ysubsize, ...
                                                zsubsize, ...
                                                xoffset, ...
                                                yoffset, ...
                                                zoffset ...
                                            );
    elseif isa(Transforms, 'containers.Map')
        % convert from global to local key
        localtforms = global2localmap(Transforms);
        % align image cube using transforms
        [ aligned ] = constructalignment(RAMONOrig.data, localtforms);
    end
    TransformsNew = Transforms;

end

% store aligned stack as RAMONVolume
RAMONAligned = RAMONOrig.clone();
RAMONAligned.setCutout(aligned);

end
