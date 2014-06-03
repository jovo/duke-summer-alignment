function [ m,b ] = folddetection( M )
%FOLDDETECTION Splits an image into two if there is a fold.
%   Detailed explanation goes here

Mbin = im2bw(M, 0.5);
[Y,X] = find(Mbin==0);
Indices = [Y,X];
[m,b] = ransac(Indices, 10);


end

