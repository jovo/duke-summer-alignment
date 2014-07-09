function [ config ] = configapivars
%CONFIGAPIVARS outputs parameters necessary for data retrieval from API for
%computing transforms. Mainly used by constructimgcubetransforms.

% config = struct;
% 
% % image token of data set
% config.imgtoken = 'kasthuri11cc';
% 
%  % resolution
% config.resolution = 4;
% 
% % total size of cube to-be aligned. Any number outside the range of the
% % data set will automatically be ended at the range of the data set.
% config.xtotalsize = intmax;
% config.ytotalsize = intmax;
% config.ztotalsize = 3;
% 
% % the size of each cube for processing.
% config.xsubsize = 1024;
% config.ysubsize = 1024;
% config.zsubsize = 2;
% 
% % the overall offset. Set to 0 for no offset.
% config.xoffset = 0;
% config.yoffset = 0;
% config.zoffset = 1;
% 
% % if parallelize is true (1), then will use parallel computing using the #
% % of workers specified in workersize.
% config.parallelize = 1;
% config.workersize = 6;

%% TEST
%   If running tests, comment out everything above, uncomment out
%   everything below.
disp('TESTING TESTING TESTING TESTING TESTING!');
disp('CONFIGAPIVARS is set to testing mode. open configapivars.m to change if necessary');
config = struct;
config.imgtoken = 'kasthuri11cc';
config.resolution = 4;
config.xtotalsize = intmax;
config.ytotalsize = intmax;
config.ztotalsize = 3;
config.xsubsize = 1024;
config.ysubsize = 1024;
config.zsubsize = 2;
config.xoffset = 0;
config.yoffset = 0;
config.zoffset = 1;
config.parallelize = 1;
config.workersize = 6;

end
