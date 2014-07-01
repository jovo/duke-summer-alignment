function [ M_new ] = window2d( M, type )
%WINDOW2D Applies a 2D window to image
%   [ M_new ] = window2d( M, type ) applies window of desired 'type'
%   to non-empty input image M

switch type
    case 'hamming'
        M = double(M);
        ywindow = hamming(size(M, 1));
        xwindow = hamming(size(M, 2));
        w = ywindow(:) * xwindow(:)';
        M_new = M.*w;
    case 'hann'
        M = double(M);
        ywindow = hann(size(M, 1));
        xwindow = hann(size(M, 2));
        w = ywindow(:) * xwindow(:)';
        M_new = M.*w;
end

end
