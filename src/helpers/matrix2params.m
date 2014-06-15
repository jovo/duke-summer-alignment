function [ params ] = matrix2params( matrix )
%MATRIX2PARAMS converts transformation matrix to vector of parameters
%   [params] = matrix2params(matrix) takes in transformation matrix 
%   dtm'd by Rotation*Translation, where TranslateX = T(3,1) and 
%   TranslateY = T(3,2) and converts it into vector of parameters,
%   params = [TranslateY, TranslateX, THETA]

TranslateX = matrix(3, 1);
TranslateY = matrix(3, 2);
ssin = matrix(2, 1);
scos = matrix(1, 1);
THETA = atan2(ssin, scos) * 180 / pi;

params = [TranslateY, TranslateX, THETA];

end
