function [ besttform, besterror, bestmerged ] = refinetformestimate( T, A, tform )
%REFINETFORMESTIMATE Improve alignment by iterating over a small range of
%possible rotation angles
%   [ besttform, besterror, bestmerged ] = refinetformestimate( T, A, tform )
%   T and A are two matrices, unaligned, and tfrom is the transformation
%   matrix that aligns T with A. The reason for this refinement is because
%   the rotation angle is discretized. By refining, a theta value within
%   the original discrete theta units may be found that minimizes error
%   function.

% retrieve global variable
global errormeasure minnonzeropercent;
if isempty(errormeasure)
    errormeasure = 'mse';
end
if isempty(minnonzeropercent)
    minnonzeropercent = 0.3;
end

% initialize best transform results with inputted values
bestmerged = affinetransform(T, A, tform);
besterror = errormetrics(bestmerged, errormeasure, '', intmax, minnonzeropercent);
besttform = tform;
if besterror == intmax  % if greater than minnonzeropercent, terminate
    return;
end
besttparam = matrix2params(tform);
invariantparam = besttparam;
bounds = 360/min(min(size(A), size(T)));

% iterate over all possible theta values in a narrow range
for theta = linspace(-bounds, bounds, 6);
    tempparam = invariantparam + [0, 0, theta];
    tempaligned = affinetransform(T, A, params2matrix(tempparam));
    temperror = errormetrics(tempaligned, errormeasure, '', intmax, minnonzeropercent);
    if temperror < besterror    % update best transform results
        besttform = params2matrix(tempparam);
        besterror = temperror;
        bestmerged = tempaligned;
    end
end

end
