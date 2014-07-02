function [ M_logpol, rho ] = log_polar( M )
%LOG_POLAR Sample image M in Log-Polar coordinates, returning M_logpol.  

[sizey, sizex] = size(M);
minsize = min(sizey, sizex);
halfminsize = minsize*0.5;
rho = logspace(0,log10(halfminsize),minsize);
theta = linspace(0,2*pi,minsize+1);
theta(length(theta)) = [];

X = rho'*cos(theta) + halfminsize;
Y = rho'*sin(theta) + halfminsize;
M_logpol = interp2(M,X,Y);
M_logpol((Y>sizey) | (Y<1) | (X>sizex) | (X<1)) = 0;

end
