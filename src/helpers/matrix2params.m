function [ TranslateY, TranslateX, THETA, SCALE ] = matrix2params( matrix )
%MATRIX2PARAMS convers transformation matrix to vector of parameters
%   Detailed explanation goes here

TranslateX = matrix(3,1);
TranslateY = matrix(3,2);
THETA = asind(matrix(2,1));
SCALE = matrix(1,1)/cosd(THETA);

end

