function [ config ] = configapivars
%CONFIGAPIVARS outputs parameters necessary for data retrieval from API

config = struct;
config.imgtoken = 'lee14';  % image token of data set
config.resolution = 1;      % resolution
% total size of cube to-be aligned. Any number outside the range of the
% data set will automatically be ended at the range of the data set.
config.xtotalsize = intmax;
config.ytotalsize = intmax;
config.ztotalsize = 5;
% the size of each cube for processing. 
config.xsubsize = 10000;
config.ysubsize = 10000;
config.zsubsize = 5;
config.xoffset = 20000;
config.yoffset = 20000;
config.zoffset = 0;
config.parallelize = 1;
config.workersize = 6;

end
