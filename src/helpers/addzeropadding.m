function [ M_new, N_new ] = addzeropadding( M, N )
%ADDZEROPADDING Adds zero padding to make same size images.
%   function [ M_new ] = addzeropadding( M, N ) adds padding to matrices M
%   or N so that they are of equal dimensions.

maxy = max(size(M, 1), size(N, 1));
maxx = max(size(M, 2), size(N, 2));
N_new = zeros(maxy, maxx);
M_new = N_new;
N_new(1:size(N, 1), 1:size(N, 2)) = N;
M_new(1:size(M, 1), 1:size(M, 2)) = M;

end

