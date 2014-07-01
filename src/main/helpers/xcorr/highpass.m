function [ M_hip ] = highpass( M )
%HIGHPASS High-pass emphasis filter

X = cos(linspace(-0.5,0.5,size(M,1)))'*cos(linspace(-0.5,0.5, size(M,2)));
H = (1-X).*(2-X);   % transfer function
M_hip = M.*H;

end
