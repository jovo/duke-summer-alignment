function [ num1, num2 ] = key2indices( key )
%KEY2INDICES Reverse of indices2key
%   [num1,num2] = key2indices(key) takes in key 'x y', a string of 
%   consecutive integers, and converts it into indices 

splitted = strsplit(key);
num1 = str2double(splitted{1});
num2 = str2double(splitted{2});

end
