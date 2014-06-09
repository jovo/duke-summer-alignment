function [ M_new, yshift, xshift ] = rmzeropadding( M, varargin )
%RMZEROPADDING Removes zero padding from image.

% validate inputs
force = 0;
if nargin == 2 && strcmpi(varargin{1}, 'force')
    force = 1;
end

if M == zeros(size(M))
    M_new = M;
    yshift = 0;
    xshift = 0;
else
    % remove horizontal/vertical padding
    [ypad, xpad] = find(M);
    M_new = M(min(ypad):max(ypad), min(xpad):max(xpad));
    yshift = min(ypad);
    xshift = min(xpad);
    % remove diagonal padding: will probably crop parts of image.
    if force
        ymin = 1;
        xmin = 1;
        ymax = size(M_new,1);
        xmax = size(M_new,2);
        while (M_new(ymin, xmin) + M_new(ymin, xmax) + M_new(ymax, xmin) + M_new(ymax, xmax)) == 0 ...
                && ymax > ymin && xmax > xmin
            xmin = xmin+1;
            xmax = xmax-1;
            ymin = ymin+1;
            ymax = ymax-1;
        end
        yshift = yshift + ymin;
        xshift = xshift + xmin;
        M_new = M_new(ymin:ymax, xmin:xmax);
    end
end

end
