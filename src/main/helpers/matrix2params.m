function [ params ] = matrix2params( matrix )
%MATRIX2PARAMS converts transformation matrix to vector of parameters
%   [params] = matrix2params(matrix) takes in transformation matrix 
%   dtm'd by trans*rot, where TX = T(3,1) and TY = T(3,2), and 
%   onverts it into vector of parameters, params = [TY, TX, TH]

% separate rotation and translation matrices
rot = [ [matrix(1:2,1:2),[0;0]]; [0,0,1] ];
trans = matrix/rot;

% determine rotation and translation parameters
ssin = rot(2, 1);
scos = rot(1, 1);
TH = -atan2(ssin, scos) * 180 / pi;
TX = trans(3, 1);
TY = trans(3, 2);

% output parameter variable
params = [TY, TX, TH];

end
