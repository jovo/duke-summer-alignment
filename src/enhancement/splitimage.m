function [separated] = splitimage(image, m, b)
%SPLITIMAGE splits the image
%   Splits image into two pieces, alternatively setting the coefficients above and below the line of best fit to zero

%[X,Y]=[row,column]
[Y,X] = ind2sub(size(image),1:size(image,1)*size(image,2)); 
fpiece = [X; Y; Y>m.*X+b]';
spiece = [X; Y; Y<m.*X+b]'; 

%to be continued 

matrix1
matrix2
separated = cat(3, matrix1, matrix2);

end

