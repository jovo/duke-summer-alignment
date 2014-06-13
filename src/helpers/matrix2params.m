function [ params ] = matrix2params( matrix )
%MATRIX2PARAMS convers transformation matrix to vector of parameters
%   Detailed explanation goes here

TranslateX = matrix(3, 1);
TranslateY = matrix(3, 2);
ssin = matrix(2, 1);
scos = matrix(1, 1);
THETA = atan2(ssin, scos) * 180 / pi;

params = [TranslateY, TranslateX, THETA];

end
