%RUNALIGN Run runalign to align everything.

% initialize global variables. See setup.m for more info.
setup();
% align all images from specific token
Transforms = alignimagecube(    'lee14', ...    % token
                                1024, ...       % xsize
                                1024, ...       % ysize
                                7);             % resolution
