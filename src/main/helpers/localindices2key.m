function [ key ] = localindices2key( num1, num2 )
%LOCALINDICES2KEY convert indices to a key for container.Map
%   [ key ] = localindices2key( num1, num2 ) converts integer indices into a
%   numeric string.

key = [int2str(num1),'_',int2str(num2)];

end
