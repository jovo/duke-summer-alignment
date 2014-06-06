function [ key ] = indices2key( num1, num2 )
%INDICES2KEY convert indices to a key for container.Map
%   Detailed explanation goes here

key = [int2str(num1),' ',int2str(num2)];
end
