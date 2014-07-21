function [ M_new, yshiftmin, xshiftmin, yshiftmax, xshiftmax ] = rmzeropadding( M, force )
%RMZEROPADDING Removes zero padding from image.
%   [ M_new, yshiftmin, xshiftmin, yshiftmax, xshiftmax ] = rmzeropadding( M, force )
%   M_new is the cropped M with variable levels of zero padding removed.
%   yshiftmin is the # of horizontally-removed zero rows from top left of image.
%   yshiftmax is the # of horizontally-removed zero rows from bottom right of image.
%   xshiftmin and xshiftmax follow. The force parameter determines the
%   number of zeros to remove.
%   force parameter missing: remove all zero rows and cols only 
%   (1): start from all four edges, remove zeros until one edge hits a
%   non-zero pixel. Some zero padding may exist, and the image may be
%   cropped.
%   (2): start from all four edges, remove zeros from each edge, one at a
%   time. This ensures that no zero padding exist, but might significantly
%   crop the image.

% validate inputs
if nargin == 1
    force = 0;
end

% if a flat image (all zeros), don't do anything.
if M == zeros(size(M))
    M_new = M;
    yshiftmin = 0;
    xshiftmin = 0;
    yshiftmax = 0;
    xshiftmax = 0;
else
    % remove padding (force parameter missing)
    [ypad, xpad] = find(M);
    M_new = M(min(ypad):max(ypad), min(xpad):max(xpad));
    yshiftmin = min(ypad)-1;
    xshiftmin = min(xpad)-1;
    yshiftmax = size(M,1)-max(ypad);
    xshiftmax = size(M,2)-max(xpad);

    % nonzero/non-missing force parameter 
    if force == 1 || force == 2
        ymin = 1;
        xmin = 1;
        ymax = size(M_new,1);
        xmax = size(M_new,2);
        if force == 1       
            while (M_new(ymin, xmin) + M_new(ymin, xmax) + M_new(ymax, xmin) + M_new(ymax, xmax)) == 0 ...
                && ymax > ymin && xmax > xmin
                xmin = xmin+1;
                xmax = xmax-1;
                ymin = ymin+1;
                ymax = ymax-1;
            end
        elseif force == 2   
            while M_new(ymin, xmin) == 0 && ymax > ymin && xmax > xmin
                xmin = xmin+1;
                ymin = ymin+1;
            end
            while M_new(ymin, xmax) == 0 && ymax > ymin && xmax > xmin
                xmax = xmax-1;
                ymin = ymin+1;
            end
            while M_new(ymax, xmin) == 0 && ymax > ymin && xmax > xmin
                ymax = ymax-1;
                xmin = xmin+1;
            end
            while M_new(ymax, xmax) == 0 && ymax > ymin && xmax > xmin
                ymax = ymax-1;
                xmax = xmax-1;
            end
        end
        % update shifted counts
        yshiftmin = yshiftmin + ymin - 1;
        xshiftmin = xshiftmin + xmin - 1;
        yshiftmax = yshiftmax + size(M_new,1) - ymax;
        xshiftmax = xshiftmax + size(M_new,2) - xmax;
        M_new = M_new(ymin:ymax, xmin:xmax);
    end
end

end
