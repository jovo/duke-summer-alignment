function [ RAMONAligned, TransformsNew ] = alignRAMONVol( RAMONOrig, Transforms )

% validate inputs
narginchk(1,2);

% retrieve data from RAMONVolume
resolution = RAMONOrig.resolution;
[ xoffset, yoffset, zoffset ] = RAMONOrig.xyzOffset;
[ ysubsize, xsubsize, zsubsize ] = size(RAMONOrig.data);

% compute alignment with/without existing transforms
if nargin == 1

    % retrieve config variables for alignment
    alignconfig = configalignvars();
    % compute alignment transforms and align image cube
    [ aligned, temptforms ] = roughalign(RAMONOrig.data, 'align', alignconfig);
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
    else
        % convert from global to local key
        localtforms = global2localmap(Transforms);
        % align image cube using transforms
        [ aligned ] = constructalignment(RAMONOrig.data, localtforms);
    end
    TransformsNew = Transforms;

end

% store aligned stack as RAMONVolume
RAMONAligned = RAMONOrig;
RAMONAligned.setCutout(aligned);

end
