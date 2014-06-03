function [separated] = splitimage(image, m, b)
%SPLITIMAGE splits the image
%   Splits image into two pieces, alternatively setting the coefficients above and below the 'fold_detection' line to zero

%
[Y,X] = ind2sub(size(image),1:size(image,1)*size(image,2)); %[Y,X]=[row,column]
f_piece = [Y; X; Y>m.*X+b]'; %bottom half
s_piece = [Y; X; Y<m.*X+b]'; %top half

f_image = zeros(size(image));
f_indices = find(f_piece(:,3)==1);
f_image(f_indices) = image(f_indices);

s_image = zeros(size(image));
s_indices = find(s_piece(:,3)==1);
s_image(s_indices) = image(s_indices);

separated = cat(3, f_image, s_image);

end

