function [ M_new ] = window2d( M, type )
%2DWINDOW Apply a hamming window to image

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
