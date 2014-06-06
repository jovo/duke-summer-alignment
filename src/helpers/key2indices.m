function [ num1, num2 ] = key2indices( key )
%KEY2INDICES Reverse of indices2key
%   Detailed explanation goes here

splitted = strsplit(key);
num1 = str2double(splitted{1});
num2 = str2double(splitted{2});

end
