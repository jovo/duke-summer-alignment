function [ localkey ] = global2localkey( globalkey )
%GLOBAL2LOCALKEY convert from global key to a key for local (depth) slices.

splitted = strsplit(globalkey, '_');
localkey = splitted{end-1:end};

end