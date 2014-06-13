function [ matrix ] = params2matrix( params )
%PARAMS2MATRIX Converts transformation parameters to matrix form
%   Takes vector of parameters and converts into 3-by-3 matrix 

TranslateY = params(1);
TranslateX = params(2);
THETA = params(3);
SCALE = params(4);
matrix = [
            SCALE*cosd(THETA),  -sind(THETA),        0; ...
            sind(THETA),       SCALE*cosd(THETA),	0; ...
            TranslateX,         TranslateY,         1
         ];

end
