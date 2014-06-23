function [ index ] = globalkey2indices( key )
%GLOBALKEY2INDICES convert global key to index
%   [ index ] = globalkey2indices( key ) converts a global key to a struct
%   index that contains global positioning data of the slice.

basekeysplit = strsplit(key, '_');

index = struct;
index.imgtoken = basekeysplit{1};
index.resolution = str2double(basekeysplit{2});
index.xoffset = str2double(basekeysplit{3});
index.yoffset = str2double(basekeysplit{4});
index.zoffset = str2double(basekeysplit{5});
index.xsize = str2double(basekeysplit{6});
index.ysize = str2double(basekeysplit{7});
slicekey = basekeysplit{8};

[index.zslice1,index.zslice2]  = key2indices(slicekey(2:end-1));

end
