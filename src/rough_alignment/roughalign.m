function [ Transforms, M_new ] = roughalign( M, varargin )
%ROUGHALIGN Aligns a stack of images
%	[ Transforms, M_new ] = roughalign( M )
%   [ Transforms, M_new ] = roughalign( M, align )
%   [ Transforms, M_new ] = roughalign( M, align, scale )
%   if align variable is 'align', M_new returns the aligned image stack;
%   otherwise M_new is nil. scale indicates how much the image should be
%   resized during the alignment process. Primarily used for large images
%   that may take up too much memory. 0.5 < scale < 1 is an appropriate
%   range. The default scale is 1. M is the image stack.

tic

% retrieve global variable
global errormeasure;
if isempty(errormeasure)
    errormeasure = 'mse';
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

% validate inputs
if size(M, 3) < 2
    error('Size of stack must be at least 2');
end
narginchk(1,3);
switch nargin
    case 1  % only image stack
        Mtemp = Mremoved;
        align = 0;
        scale = 1;
    case 2  % image stack with align params
        Mtemp = Mremoved;
        align = strcmpi(varargin{1}, 'align');
        scale = 1;
    case 3  % image stack, align, and scale params
        Mtemp = imresize(Mremoved, varargin{2});
        align = strcmpi(varargin{1}, 'align');
        scale = varargin{2};
end

% compute pairwise transforms
tformstemp  = constructtransforms(Mtemp, 'improve');
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
M_new = [];
if align

    % global alignment using piecewise transformation parameters
    M_new = constructalignment(Mremoved, Transforms);

    % add back removed image slices
    if removed(1)
        M_new = cat(3, zeros(size(M_new(:,:,1)), 'uint8'), M_new);
    end
    for i=2:size(M,3)
        if removed(i)
            M_new = cat(3, M_new(:,:,1:i-1), zeros(size(M_new(:,:,i)), 'uint8'), M_new(:,:,i:end));
        end
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

toc

end
