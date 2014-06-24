function [ index ] = globalkey2indices( key )
%GLOBALKEY2INDICES convert global key to index
%   [ index ] = globalkey2indices( key ) converts a global key to a struct
%   index that contains global positioning data of the slice.

basekeysplit = strsplit(key, '_');
basekeysplit(2:end) = str2double(str2double(basekeysplit(2:end));

index = struct;
index.imgtoken = basekeysplit{1};
index.resolution = basekeysplit{2};
index.xoffset = basekeysplit{3};
index.yoffset = basekeysplit{4};
index.xsubsize = basekeysplit{5};
index.ysubsize = basekeysplit{6};
index.zslice1 = basekeysplit{7};
index.zslice2 = basekeysplit{8};

end
