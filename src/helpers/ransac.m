function [ maxM, maxB, inrangeprop ] = ransac( Indices, d )
%RANSAC Custom implementation of Random Sample Consensus of linear model.
%   [ maxM, maxB, epsilon ] = ransac( Indices, d ) Indices are the [Y,X] indices of
%   the points of interest. d is the width of points from the model that
%   can be considered to be inliers. epsilon indicates the fraction of
%   outliers.

% find a random point from list of points
function [ points ] = randpoint(indices, count)
    numInd = size(indices,1);
    randRow = randi([1,numInd],[count,1]);
    points = indices(randRow,:);
    if points(1,2) == points(2,2) && points(1,1) == points(2,1) % ensures for count = 2, unique points 
        points = randpoint(indices, count);
    end
end

% fit a line in standard form to two points
function [ A, B, C ] = fitline(point1, point2)
    if point1(2) ~= point2(2)
        A = (point1(1)-point2(1))/(point1(2)-point2(2));
        B = -1;
        C = point1(1)-point1(2)*A; % A = slope
    else 
        A = -1;
        B = 0;
        C = point1(2);
    end    
end

% begin ransac algorithm 
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
    [A,B,C] = fitline(pts(1,:), pts(2,:));
    inrange = (A*Indices(:,2)+B*Indices(:,1)+C <= d*sqrt(A^2+B^2));
          
    inrangecount = sum(inrange);
    
    if inrangecount > maxinrange
        maxinrange = inrangecount;
        maxM = A;  
        maxB = C; 
    end
    
    outlierfract = 1-inrangecount/totalcount;
    if outlierfract < epsilon
        epsilon = outlierfract;
    end
    N = ceil(log(1-0.995)/log(1-(1-epsilon)^s));
    i = i+1;
end

inrangeprop = 1-epsilon;

end
