function [ M_new, N_new, Merged ] = removezeropadding( M, N, Merged )
%REMOVEZEROPADDING Removes zero padding from all sides of image.
%   function [ M_new, N_new, Merged ] = removezeropadding( M, N, Merged )

[ycoord, xcoord] = find(Merged);
N_new = N(min(ycoord):max(ycoord), min(xcoord):max(xcoord));
M_new = M(min(ycoord):max(ycoord), min(xcoord):max(xcoord));
Merged = Merged(min(ycoord):max(ycoord), min(xcoord):max(xcoord));

end

