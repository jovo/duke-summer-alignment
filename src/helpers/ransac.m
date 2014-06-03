function [ maxM, maxB, inrangeprop ] = ransac( Indices, d )
%RANSAC Custom implementation of Random Sample Consensus of linear model.
%   [ maxM, maxB, epsilon ] = ransac( Indices, d ) Indices are the [Y,X] indices of
%   the points of interest. d is the width of points from the model that
%   can be considered to be inliers. epsilon indicates the fraction of
%   outliers.

totalcount = size(Indices, 1);
s = 2;
N = 1;
epsilon = 0.5;
i = 0;

maxinrange = 0;
maxM = 0;
maxB = 0;

while i < N
    pts = randpoint(Indices, 2);
    [m, b] = fitline(pts(1,:), pts(2,:));
    inrange = ( ...
                Indices(:,2)*m+(b-d) < Indices(:,1) & ...
                Indices(:,2)*m+(b+d) > Indices(:,1) ...
              );
    inrangecount = sum(inrange);
    if inrangecount > maxinrange
        maxinrange = inrangecount;
        maxM = m;
        maxB = b;
    end
    outlierfract = 1-inrangecount/totalcount;
    if outlierfract < epsilon
        epsilon = outlierfract;
    end
    N = ceil(log(1-0.995)/log(1-(1-epsilon)^s));
    i = i+1;
end

inrangeprop = 1-epsilon;

    % find a random point from list of points
    function [ points ] = randpoint(indices, count)
        points = indices(ceil(rand(count,1)*size(indices,1)),:);
    end

    % fit a line to two points
    function [ m, b ] = fitline(point1, point2)
        m = (point1(1)-point2(1))/(point1(2)-point2(2));
        b = point1(1)-point1(2)*m;
    end

end
