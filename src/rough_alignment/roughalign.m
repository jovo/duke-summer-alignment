function [ Transforms, M_new ] = roughalign( M, varargin )
%ROUGHALIGN Aligns a stack of images
%	[ Transforms ] = roughalign( M ) computes the transforms for image 
%   cube M.
%   [ Transforms, M_new ] = roughalign( M, action ) if action is 'align',
%   also calls 'constructalignment' to apply to the transforms to image
%   stack M. otherwise M_new is nil.
%   
%	each image pair. 

% validate inputs
narginchk(1,2);

Transforms = constructtransforms(M);
M_new = [];
if nargin == 2 && strcmpi(varargin{1}, 'align')
    M_new = constructalignment(M, Transforms);
    % output error 
    [originalerror, original] = errorreport(M, 'Original', 'mse');
    [alignederror, aligned] = errorreport(M_new, 'Aligned', 'mse');
    disp('Error improvement:');
    disp(originalerror-alignederror);
    disp(original);
    disp(aligned);
end

end


