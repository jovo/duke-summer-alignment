function [ params ] = matrix2params( matrix )
%MATRIX2PARAMS convers transformation matrix to vector of parameters
%   Detailed explanation goes here

TranslateX = matrix(3, 1);
TranslateY = matrix(3, 2);
ssin = matrix(2, 1);
scos = matrix(1, 1);
SCALE = sqrt(ssin * ssin + scos * scos);
THETA = atan2(ssin, scos) * 180 / pi;

% THETA = asind(matrix(2,1));
% SCALE = matrix(1,1)/cosd(THETA);

params = [TranslateY, TranslateX, THETA, SCALE, 0];

end
