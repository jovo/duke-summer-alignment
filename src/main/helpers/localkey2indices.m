function [ num1, num2 ] = localkey2indices( key )
%LOCALKEY2INDICES Reverse of localindices2key
%   [ num1, num2 ] = localkey2indices( key ) takes in key 'x_y', a string of 
%   consecutive integers, and converts it into indices.

splitted = strsplit(key, '_');
num1 = str2double(splitted{1});
num2 = str2double(splitted{2});

end
