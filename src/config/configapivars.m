function [ config ] = configapivars
%CONFIGAPIVARS outputs parameters necessary for data retrieval from API for
%computing transforms. Mainly used by constructimgcubetransforms.

config = struct;

% image token of data set
config.imgtoken = 'kasthuri11cc';

 % resolution
config.resolution = 1;

% total size of cube to-be aligned. Any number outside the range of the
% data set will automatically be ended at the range of the data set.
config.xtotalsize = intmax;
config.ytotalsize = intmax;
config.ztotalsize = 3;

% the size of each cube for processing.
config.xsubsize = 1024;
config.ysubsize = 1024;
config.zsubsize = 2;

% the overall offset. Set to 0 for no offset.
config.xoffset = 0;
config.yoffset = 0;
config.zoffset = 1;

% if parallelize is true (1), then will use parallel computing using the #
% of workers specified in workersize.
config.parallelize = 1;
config.workersize = 6;

end
