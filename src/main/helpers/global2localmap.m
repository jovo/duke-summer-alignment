function [ localtforms ] = global2localmap( globaltforms )
%GLOBAL2LOCALMAP Convert entire map from global to local key.
%   [ localtforms ] = global2localmap( globaltforms ) Assumed for map to
%   only contain one image stack. globaltforms is a Map that has keys in
%   global coordinates. localtforms is Map with keys in local coordinates.

% iterate over each map entry, convert from global to local key
localtforms = containers.Map;
k = keys(globaltforms);
for i=1:length(k)
    localkey = global2localkey(k{i});
    localval = values(globaltforms, k(i));
    localtforms(localkey) = localval{1};
end

    %% helper function
    function [ localkey ] = global2localkey( globalkey )
    %GLOBAL2LOCALKEY convert from global key to a key for local (depth) slices.

    splitted = strsplit(globalkey, '_');
    endtemp = splitted(end-1:end);
    doubletemp = str2double(endtemp) - str2double(splitted{4});
    localkey = [num2str(doubletemp(1)), '_', num2str(doubletemp(2))];

    end

end
