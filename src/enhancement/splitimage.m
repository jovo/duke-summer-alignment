function [separated] = splitimage(image, m, b)
%SPLITIMAGE splits the image
%   Given slope m and y-intercept b of 'fold_detection' line, splits image into two pieces, alternatively setting the coefficients above and below the line to zero

%gives indices of separated images in matrix form
[Y,X] = ind2sub(size(image),1:size(image,1)*size(image,2)); %indices: [Y,X]=[row,column]
f_piece = [Y; X; Y>=m.*X+b]'; 
s_piece = [Y; X; Y<=m.*X+b]';

%bottom half of image
f_image = zeros(size(image));
f_indices = find(f_piece(:,3)==1);
f_image(f_indices) = image(f_indices);

%top half of image 
s_image = zeros(size(image));
s_indices = find(s_piece(:,3)==1);
s_image(s_indices) = image(s_indices);

separated = cat(3, f_image, s_image);

end

