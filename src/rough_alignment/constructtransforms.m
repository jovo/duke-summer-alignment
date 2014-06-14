function [ Transforms ] = constructtransforms( M, varargin )
%CONSTRUCTTRANSFORMS determines transform parameters to align pairwise
%images from image cube.
%   [ Transforms ] = constructtransforms( M )
%   [ Transforms ] = constructtransforms( M, improve ) M is the image
%   stack, the optional improve parameter attempts to correct faulty
%   alignments by using adjacent images.

% retrieve global variable
global errormeasure minnonzeropercent;
if isempty(errormeasure)
    errormeasure = 'mse';
end
if isempty(minnonzeropercent)
    minnonzeropercent = 0.3;
end

% validate inputs
improve = 0;
if nargin == 2 && strcmpi(varargin{1}, 'improve')
    improve = 1;
end

% stores variables as matfile to save memory
filename = strcat('constructtransform_tempfile_', lower(randseq(8, 'Alphabet', 'amino')), '.mat');
save(filename, 'M', '-v7.3');
data = matfile(filename, 'Writable', true);
looplength = size(M, 3) - 1;
ids = cell(1, looplength);
tforms = cell(1, looplength);
newerrors = NaN(1, looplength);
origerrors = NaN(1, looplength);
errordiff = NaN(1, looplength);
errorupdate = [0,0];
clear M;

%% iterate through stack, compute transformations for rough alignment.
for i=1:looplength
    % two images of interest.
    img1 = data.M(:,:,i);
    img2 = data.M(:,:,i+1);

    origerrors(1,i) = errormetrics(data.M(:,:,i:i+1), errormeasure, '', intmax, minnonzeropercent);
    % feature match for rough angle alignment, then xcorr for precision.
    [tform1, merged1] = featurematch2imgs(img2, img1);
    [error1, ~] = errormetrics(merged1, errormeasure, '', intmax, minnonzeropercent);
    if error1 < origerrors(1,i)
        tform = tform1;
        error = error1;
    else
        tform = eye(3);
        error = origerrors(1,i);
    end

    % because transforms are discrete, minimize slight error in theta
    % values. the best params are initially set to no transforms at all.
    besttparam = matrix2params(tform);
    besterror = error;
    invariantparam = besttparam;
    bounds = 360/min(min(size(img1), size(img2)));
    for theta = linspace(-bounds, bounds, 6);
        tempparam = invariantparam + [0, 0, theta];
        tempaligned = affinetransform(img2, img1, params2matrix(tempparam));
        [temperror, tempflag] = errormetrics(tempaligned, errormeasure, '', intmax, minnonzeropercent);
        if ~tempflag && temperror < besterror
            besttparam = tempparam;
            besterror = temperror;
        end
    end
    updatedtform = params2matrix(besttparam);
    updatedmerged = affinetransform(img2, img1, updatedtform);

    % store ids and transforms, and error
    ids(1,i) = {indices2key(i, i+1)};
    tforms(1,i) = {updatedtform};
    newerrors(1,i) = errormetrics(updatedmerged, errormeasure, '', intmax, minnonzeropercent);
    errordiff(1,i) = origerrors(1,i)-newerrors(1,i);

    % conditions to update error.
    if errordiff(1,i) < 0
        errorupdate = cat(1, errorupdate, [i, i+1]);
    end
end
errorupdate = errorupdate(2:end,:);

% save ids and transforms into table.
Transforms = containers.Map(ids, tforms);

if improve
    %% minimize error caused by transformations with linear programming.
    % let index1 and index2 be the indices of images and its corresponding
    % transformation parameters we wish to optimize. Let preindex be the index
    % of image immediately before index1, postindex the index of image
    % immediately after index2.
    addtforms = containers.Map;  % table for storing additional alignment transform params
    for i=1:size(errorupdate, 1)

        % important indices
        index1 = errorupdate(i,1);
        index2 = errorupdate(i,2);
        preindex = index1 - 1;
        postindex = index2 + 1;

        % compute additional alignments (preindex to index2, index1 to postindex)
        if preindex >= 1 && ~isKey(addtforms, {indices2key(preindex, index2)})
            img1 = data.M(:,:, preindex);
            img2 = data.M(:,:, index2);
            tform = xcorr2imgs(img2, img1, '', 'pad');
            addtforms(indices2key(preindex, index2)) = tform;
        end
        if postindex <= looplength+1 && ~isKey(addtforms, {indices2key(index1, postindex)})
            img1 = data.M(:,:, index1);
            img2 = data.M(:,:, postindex);
            tform = xcorr2imgs(img2, img1, '', 'pad');
            addtforms(indices2key(index1, postindex)) = tform;
        end

        % retrieve transformation parameters from additional alignments.
        % preT are the transform params based on preindex, index1, index2.
        % postT are the transform aprams based on index1, index2,
        % postindex. Also retrieves transformation error. If no adjacent
        % images exist, then the error is set to intmax.
        if preindex >= 1
            val1 = values(addtforms, {indices2key(preindex, index2)});
            B = val1{1};
            val2 = values(Transforms, {indices2key(preindex, index1)});
            A = val2{1};
            preT = A\B;
            pretf = affinetransform(data.M(:,:,index2), data.M(:,:,index1), preT);
            preTerror = errormetrics(pretf, errormeasure, '', intmax, minnonzeropercent);
        else
            preT = eye(3);
            preTerror = intmax;
        end
        if postindex <= looplength + 1
            val1 = values(addtforms, {indices2key(index1, postindex)});
            B = val1{1};
            val2 = values(Transforms, {indices2key(index2, postindex)});
            A = val2{1};
            postT = B/A;
            posttf = affinetransform(data.M(:,:,index2), data.M(:,:,index1), postT);
            postTerror = errormetrics(posttf, errormeasure, '', intmax, minnonzeropercent);
        else
            postT = eye(3);
            postTerror = intmax;
        end

        % retrieves original transform and error
        curT = tforms{1, index1};
        Terror = newerrors(1, index1);

        % retrieves trivial solution: no transformation at all
        nochangeT = eye(3);
        nochangeTerror = origerrors(1, index1);

        % solve linear program
        f = [double(preTerror); double(postTerror); double(Terror); double(nochangeTerror)];
        A = [];
        b = [];
        Aeq = [1, 1, 1, 1];
        beq = 1;
        lb = [0; 0; 0; 0];
        ub = [1; 1; 1; 1];
        x = linprog(f, A, b, Aeq, beq, lb, ub);

        % use solution from LP to find optimal transformation parameters.
        Tupdated = x(1).*preT + x(2).*postT + x(3).*curT + x(4).*nochangeT;
        Transforms(indices2key(index1, index2)) = Tupdated;

    end
end

delete(filename);

end

%     % with matlab's image registration function
%     tform = imregtform(img1, img2, 'rigid', ...
%         registration.optimizer.RegularStepGradientDescent, ...
%         registration.metric.MeanSquares);
