function [ separated ] = splitimage( image, m, b, d )
%SPLITIMAGE splits the image into two
%   [ separated ] = splitimage( image, m, b, d ) Slope m and y-intercept b 
%   are from 'fold_detection' line. separated contains the separated parts
%   of image, assumes there is single, linear, non-vertical fold line. d is
%   distance above/below line in which we seek to capture fold. 

% gives indices of separated images in matrix form
[Y,X] = ind2sub(size(image),1:size(image,1)*size(image,2)); 
f_piece = [Y; X; Y>=m.*X+b+d]';
s_piece = [Y; X; Y<=m.*X+b-d]';

% image below line
f_image = zeros(size(image));
f_indices = find(f_piece(:,3)==1);
f_image(f_indices) = image(f_indices);

% image above line
s_image = zeros(size(image));
s_indices = find(s_piece(:,3)==1);
s_image(s_indices) = image(s_indices);

separated = cat(3, f_image, s_image);

end
