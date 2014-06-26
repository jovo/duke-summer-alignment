function [ Transforms, M_new ] = roughalign( M, varargin )
%ROUGHALIGN Aligns a stack of images
%	[ Transforms, M_new ] = roughalign( M )
%   [ Transforms, M_new ] = roughalign( M, align, scale, config )
%   if align variable is 'align', M_new returns the aligned image stack;
%   otherwise M_new is nil. scale indicates how much the image should be
%   resized during the alignment process. Primarily used for large images
%   that may take up too much memory. 0.5 < scale < 1 is an appropriate
%   range. The default scale is 1. M is the image stack.

% validate inputs
narginchk(1,4);
if size(M, 3) < 2
    error('Size of stack must be at least 2');
end

% remove images that are all one color
removed = false(size(M, 3),1);
for i=1:size(M, 3)
    curimage = M(:,:,i);
    if std(double(curimage(:))) == 0
        removed(i) = 1;
    end
end
Mremoved = M(:,:,~removed);

% initialize output variable
M_new = [];

% if # of valid images (after invalid img removal) is < 2, then return
if size(Mremoved, 3) < 2
    Transforms = containers.Map();
    return;
end

% parse inputs
align = 0;
if nargin > 1
    align = strcmpi(varargin{1}, 'align');
end
scale = 1;
Mtemp = Mremoved;
if nargin > 2 && varargin{2} ~= 1
    scale = varargin{2};
    Mtemp = imresize(Mremoved, scale);
end
config = struct;
if nargin > 3
    config = varargin{3};
end

% retrieve config variable
try
    errormeasure = config.errormeasure;
catch
    errormeasure = 'mse';
end

% compute pairwise transforms
tformstemp  = constructtransforms(Mtemp, config);
Transforms = tformstemp;

% undo the initial resizing
if scale ~= 1
	keySet = keys(tformstemp);
	for i=1:length(keySet)
        val = values(tformstemp, keySet(i));
        params = matrix2params(val{1});
        params(1:2) = params(1:2)/scale;
        newmatrix = params2matrix(params);
        Transforms(keySet{i}) = newmatrix;
	end
end

% aligns the image based on the transforms if required
if align

    % global alignment using piecewise transformation parameters
    M_new = constructalignment(Mremoved, Transforms);

    origIndices = 1:size(M_new,3);
    % add back removed image slices
    if removed(1)
        M_new = cat(3, zeros(size(M_new(:,:,1)), 'uint8'), M_new);
        origIndices = origIndices + 1;
    end
    for i=2:size(M,3)
        if removed(i)
            M_new = cat(3, M_new(:,:,1:i-1), zeros(size(M_new(:,:,i)), 'uint8'), M_new(:,:,i:end));
            origIndices(i:end) = origIndices(i:end)+1;
        end
    end

    % update transform map keys after adding back image slices
    keySet = keys(Transforms);
    for i=1:size(origIndices)-1
        curVal = values(Transforms, keySet(i));
        remove(Transforms, keySet{i});
        Transforms(indices2key(origIndices(i), origIndices(i+1))) = curVal;
    end

    % output error report for both original and aligned stacks.
    format short g;
    [origE, orig] = errorreport(M, 'Original', errormeasure);
    [alignedE, aligned] = errorreport(M_new, 'Aligned', errormeasure);
    disp('Error improvement:');
    disp([sprintf('\tIndex\tImprovement\t'), '% Improvement']);
    disp( [(1:size(origE,1))', origE-alignedE, (origE-alignedE)./origE] );
    disp(orig);
    disp(aligned);
end

end
