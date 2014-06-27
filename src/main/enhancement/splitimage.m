function [separated] = splitimage(image, m, b, d)
%SPLITIMAGE splits the image
%   Given slope m and y-intercept b of 'fold_detection' line, splits image
%   into two pieces, alternatively setting the coefficients above and below
%   the line to zero.

%gives indices of separated images in matrix form
[Y,X] = ind2sub(size(image),1:size(image,1)*size(image,2)); %indices: [Y,X]=[row,column]
f_piece = [Y; X; Y>=m.*X+b+d]';
s_piece = [Y; X; Y<=m.*X+b-d]';

%image below line
f_image = zeros(size(image));
f_indices = find(f_piece(:,3)==1);
f_image(f_indices) = image(f_indices);

%image above line
s_image = zeros(size(image));
s_indices = find(s_piece(:,3)==1);
s_image(s_indices) = image(s_indices);

separated = cat(3, f_image, s_image);

end
