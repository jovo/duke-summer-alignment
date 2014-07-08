function [ RAMONAligned, TransformsNew ] = alignRAMONVol( RAMONOrig, Transforms )
%ALIGNRAMONVOL Aligns RAMONVolumes
%   [ RAMONAligned, TransformsNew ] = alignRAMONVol( RAMONOrig, Transforms )
%   RAMONOrig is the unaligned image stack, Transforms is an optional
%   argument. Transforms can either be a structure outputted from
%   constructimgcubetransforms that contains the containers.Map or the
%   transform map themselves. If there is no Transforms parameter, then it
%   calculates the transforms and outputs them in a containers.Map object
%   TransformsNew. RAMONAligned is the aligned RAMONOrig.

tic

% validate inputs
narginchk(1,2);

% retrieve data from RAMONVolume
resolution = RAMONOrig.resolution;
xyz = RAMONOrig.xyzOffset;
xoffset = xyz(1);
yoffset = xyz(2);
zoffset = xyz(3);
[ ysubsize, xsubsize, zsubsize ] = size(RAMONOrig.data);

% compute alignment without existing transforms
if nargin == 1

    % retrieve config variables for alignment
    alignconfig = configalignvars();
    % compute alignment transforms and align image cube
    [ TransformsNew, aligned ] = roughalign(RAMONOrig.data, 'align', alignconfig);
    % convert from local key back to global key
    TransformsNew.pairwise = local2globalmap( ...
                                        TransformsNew.pairwise, ...
                                        resolution, ...
                                        xoffset, ...
                                        yoffset, ...
                                        zoffset, ...
                                        xsubsize, ...
                                        ysubsize ...
                                    );

    TransformsNew.global = local2globalmap( ...
                                        TransformsNew.global, ...
                                        resolution, ...
                                        xoffset, ...
                                        yoffset, ...
                                        zoffset, ...
                                        xsubsize, ...
                                        ysubsize ...
                                    );
elseif nargin == 2
    try
        Transforms.transforms;
        isentire = 1;
    catch
        isentire = 0;
    end
    % if the Transforms is for the ENTIRE data set
    if isentire
        aligned = constructimgcubealignment(    Transforms, ...
                                                xsubsize, ...
                                                ysubsize, ...
                                                zsubsize, ...
                                                xoffset, ...
                                                yoffset, ...
                                                zoffset ...
                                            );
    % if the Transforms only apply to the current image cube
    else
        % convert from global to local key
        Transforms.pairwise = global2localmap(Transforms.pairwise);
        Transforms.global = global2localmap(Transforms.global);
        % align image cube using transforms
        [ aligned ] = constructalignment(RAMONOrig.data, Transforms);
    end
    TransformsNew = Transforms;

end

% store aligned stack as RAMONVolume
RAMONAligned = RAMONOrig.clone();
RAMONAligned.setCutout(aligned);

toc

end
