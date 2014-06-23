%RUNALIGN Run runalign to align everything.

% align all images from specific token
Transforms = computeimgcubetransforms(  'lee14', ...    % token
                                        1024, ...       % xsize
                                        1024, ...       % ysize
                                        1);             % resolution
