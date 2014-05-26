function [ M_new, N_new, Merged ] = removezeropadding( varargin )
%REMOVEZEROPADDING Removes zero padding from all sides of image.
%   function [ M_new ] = removezeropadding( M ) Removes zero padding from
%   one image, independently of all others
%   function [ M_new, N_new, Merged ] = removezeropadding( M, N, Merged )
%   Removes zero padding from Merged, and applies the same removal to M and
%   N.

if nargin==1
    M = varargin{1};
    [ycoord, xcoord] = find(M);
    M_new = M(min(ycoord):max(ycoord), min(xcoord):max(xcoord));
elseif nargin==3
    M = varargin{1};
    N = varargin{2};
    Merged = varargin{3};
    [ycoord, xcoord] = find(Merged);
    N_new = N(min(ycoord):max(ycoord), min(xcoord):max(xcoord));
    M_new = M(min(ycoord):max(ycoord), min(xcoord):max(xcoord));
    Merged = Merged(min(ycoord):max(ycoord), min(xcoord):max(xcoord));
end

