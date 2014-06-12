function [ M_new ] = hamming2dwindow( M )
%HAMMING2DWINDOW Apply a hamming window to image

M = double(M);
ywindow = hamming(size(M, 1));
xwindow = hamming(size(M, 2));
w = ywindow(:) * xwindow(:)';
M_new = M.*w;

end
