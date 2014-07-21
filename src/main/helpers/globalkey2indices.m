function [ index ] = globalkey2indices( key )
%GLOBALKEY2INDICES convert global key to index
%   [ index ] = globalkey2indices( key ) converts a global key to a struct
%   index that contains global positioning data of the slice.

basekeysplit = str2double(strsplit(key, '_'));

index = struct;
index.resolution = basekeysplit{1};
index.xoffset = basekeysplit{2};
index.yoffset = basekeysplit{3};
index.zoffset = basekeysplit{4};
index.xsubsize = basekeysplit{5};
index.ysubsize = basekeysplit{6};
index.zslice1 = basekeysplit{7};
index.zslice2 = basekeysplit{8};

end
