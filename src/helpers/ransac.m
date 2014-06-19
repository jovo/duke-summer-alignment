function [ bestA, bestB, bestC, inrangeprop ] = ransac( Indices, d )
%RANSAC Custom implementation of Random Sample Consensus of linear model.
%   [ bestA, bestB, bestC, inrangeprop ] = ransac( Indices, d ) Indices are 
%   the [Y,X] indices of the points of interest. d is the width of points 
%   from the model that can be considered to be inliers. epsilon indicates 
%   the fraction of outliers. 

totalcount = size(Indices,1);
s = 2;
N = 1;
epsilon = 0.5;
i = 0;

bestinrange = 0;
bestA = 0;
bestB = 0;
bestC = 0;

% iterates through until #interations > N 
while i < N
    pts = randpoint(Indices, 2);
    [A, B, C] = fitline(pts(1,:), pts(2,:));    

    % find vector from pts used to fit line   
    u = pts(2,:) - pts(1,:);

    % project v onto u, find perpendicular distance vperp 
    v = [Indices(:,1)-pts(1,1), Indices(:,2)-pts(1,2)]; % nx2
    vmag = sqrt(v(:,1).^2 + v(:,2).^2)'; % 1xn, magnitude of v
    vpara = ((u*v')/(u*u')); % 1xn
    vperp = sqrt(vmag.^2 - vpara.^2); % 1xn

    % find #inliers within d, update output variables
    [~,X] = find(vperp <= d);
    inrangecount = size(X,2);
    if inrangecount > bestinrange
        bestinrange = inrangecount;
        bestA = A;  
        bestB = B;
        bestC = C;
    end
    outlierfract = 1-inrangecount/totalcount; 
    if outlierfract < epsilon
        epsilon = outlierfract;
    end
    
    % update iteration parameters
    N = ceil(log(1-0.995)/log(1-(1-epsilon)^s));
    i = i+1;
end
inrangeprop = 1-epsilon;

end

% find random points from points of interest
function [ points ] = randpoint(indices, count)
    numInd = size(indices,1);
    randRow = randi([1,numInd],[count,1]);
    points = indices(randRow,:);
    if points(1,:) == points(2,:)
        [points] = randpoint(indices, count);
    end
end

% fit a line in standard form to two points
function [ A, B, C] = fitline(point1, point2)
P = [point1(2), point1(1); point2(2), point2(1)];
Z = ones(2,1);
x = P\Z;
A = x(1);
B = x(2);
C = -1;
end
