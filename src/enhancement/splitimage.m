function [separated] = splitimage(image, m, b)
%SPLITIMAGE splits the image
%   Splits image into two pieces, alternatively setting the coefficients above and below the line of best fit through the fold to zero

%[Y,X]=[row,column]
[Y,X] = ind2sub(size(image),1:size(image,1)*size(image,2)); 
fpiece = [X; Y; Y>m.*X+b]'; %bottom half
spiece = [X; Y; Y<m.*X+b]'; %top half

%to be continued...

matrix1
matrix2
separated = cat(3, matrix1, matrix2);

end

