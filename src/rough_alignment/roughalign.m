function [ Transforms, M_new ] = roughalign( M, varargin )
%ROUGHALIGN Aligns a stack of images
%	[ Transforms ] = roughalign( M )
%   [ Transforms, M_new ] = roughalign( M, align )
%   [ Transforms, M_new ] = roughalign( M, align, scale )
%   if align is true (1), M_new returns the aligned image stack; otherwise
%   M_new is nil. scale indicates how much the image should be resized
%   during the alignment process. Primarily used for large images that may
%   take up too much memory. 0.5 < scale < 1 is an appropriate range. The
%   default scale is 1. M is the image stack.

tic

% validate inputs
if size(M, 3) < 2
    error('Size of stack must be at least 2');
end
narginchk(1,3);
switch nargin
    case 1  % only image stack
        Mtemp = M;
        align = 0;
    case 2  % image stack with align params
        Mtemp = M;
        align = varargin{1};
    case 3  % image stack, align, and scale params
        Mtemp = imresize(M, varargin{2});
        align = varargin{2};
end

% compute pairwise transforms
Transforms = constructtransforms(Mtemp);

% aligns the image based on the transforms if required
M_new = [];
if align
    M_new = constructalignment(M, Transforms);
    % output error report for both original and aligned stacks.
    [originalerror, original] = errorreport(M, 'Original', 'sse');
    [alignederror, aligned] = errorreport(M_new, 'Aligned', 'sse');
    disp('Error improvement:');
    disp(originalerror-alignederror);
    disp(original);
    disp(aligned);
end

toc

end
