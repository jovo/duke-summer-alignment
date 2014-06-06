function [ Transforms ] = constructtransforms( M, varargin )
%CONSTRUCTTRANSFORMS determines transform parameters to align pairwise
%images from image cube.

% validate inputs
improve = 0;
if nargin == 2 && strcmpi(varargin{1}, 'improve')
    improve = 1;
end

% stores variables as matfile to save memory
filename = strcat('tempfiledeletewhendone_',lower(randseq(8, 'Alphabet','amino')),'.mat');
save(filename,'M','-v7.3');
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
    img1 = data.M(:,:,i);
    img2 = data.M(:,:,i+1);

    % with own function (0= don't align, 1=pad)
    [tform] = xcorr2imgs(img2, img1, '', 1);
    % because transforms are discrete, minimize slight possible error
    % check -1 < TranslateX < 1, -1 < TranslateY < 1, -1 < THETA < 1
    besttparam = [0,0,0,1,0];
    besterror = errormetrics(data.M(:,:,i:i+1), 'pxdiff', 0.5, '', intmax);
    pretform = {besttparam; affine2d(params2matrix(besttparam))};
    tempparam = tform{1};
    for theta = -360/min(size(img1)):0.2:360/min(size(img1))
        newtp = tempparam + [0, 0, theta, 0, 0];
        aligned = affinetransform(img2, img1, {newtp; affine2d(params2matrix(newtp))}, pretform);
        [errorfn, flag] = errormetrics(aligned, 'pxdiff', 0.5);
        if ~flag && errorfn < besterror
            besttparam = newtp;
            besterror = errorfn;
        end
    end
    updatedtform = {besttparam; affine2d(params2matrix(besttparam))};
    merged = affinetransform(img2, img1, updatedtform, pretform);
    % store ids and transforms, and error
    ids(1,i) = {indices2key(i, i+1)};
    tforms(1,i) = {updatedtform};
    newerrors(1,i) = errormetrics(merged, 'pxdiff', 0.5, '', intmax);
    origerrors(1,i) = errormetrics(data.M(:,:,i:i+1), 'pxdiff', 0.5, '', intmax);
    errordiff(1,i) = origerrors(1,i)-newerrors(1,i);

    % conditions to update error.
%     if errordiff(1,i) < 0
        errorupdate = cat(1, errorupdate, [i, i+1]);
%     end
end
errorupdate = errorupdate(2:end,:);
clear img1 img2 merged aligned;

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
            tform = xcorr2imgs(img2, img1, '', 1);
            addtforms(indices2key(preindex, index2)) = tform;
        end
        if postindex <= looplength+1 && ~isKey(addtforms, {indices2key(index1, postindex)})
            img1 = data.M(:,:, index1);
            img2 = data.M(:,:, postindex);
            tform = xcorr2imgs(img2, img1, '', 1);
            addtforms(indices2key(index1, postindex)) = tform;
        end

        % retrieve transformation parameters from additional alignments.
        % preT are the transform params based on preindex, index1, index2.
        % postT are the transform aprams based on index1, index2,
        % postindex. Also retrieves transformation error. If no adjacent
        % images exist, then the error is set to intmax.
        identparams = [0,0,0,1,0];
        identT = {identparams;affine2d(params2matrix(identparams))};
        if preindex >= 1
            val1 = values(addtforms, {indices2key(preindex, index2)});
            B = val1{1}{2}.T;
            val2 = values(Transforms, {indices2key(preindex, index1)});
            A = val2{1}{2}.T;
            preT = matrix2params(A\B);
            preTcell = {preT; affine2d(params2matrix(preT))};
            pretf = affinetransform(data.M(:,:,index2), data.M(:,:,index1), preTcell, identT);
            preTerror = errormetrics(pretf, 'pxdiff', 0.5, '', intmax);
        else
            preT = [0,0,0,1,0];
            preTerror = intmax;
        end
        if postindex <= looplength + 1
            val1 = values(addtforms, {indices2key(index1, postindex)});
            B = val1{1}{2}.T;
            val2 = values(Transforms, {indices2key(index2, postindex)});
            A = val2{1}{2}.T;
            postT = matrix2params(B/A);
            postTcell = {postT; affine2d(params2matrix(postT))};
            posttf = affinetransform(data.M(:,:,index2), data.M(:,:,index1), postTcell, identT);
            postTerror = errormetrics(posttf, 'pxdiff', 0.5, '', intmax);
        else
            postT = [0,0,0,1,0];
            postTerror = intmax;
        end

        % retrieves original transform and error
        currentT = values(Transforms, {indices2key(index1, index2)});
        currentT = currentT{1};
        curT = currentT{1};
        Terror = newerrors(1, index1);

        % retrieves trivial solution: no transformation at all
        nochangeTerror = origerrors(1, index1);
        nochangeT = [0,0,0,1,1];

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
        Tupdated = x(1)*preT + x(2)*postT + x(3)*curT + x(4)*nochangeT;
        Tupmat = params2matrix(Tupdated);
        Transforms(indices2key(index1, index2)) = {Tupdated; affine2d(Tupmat)};

    end
end

delete(filename);

end




%     % with matlab's image registration function
%     tform = imregtform(img1, img2, 'rigid', ...
%         registration.optimizer.RegularStepGradientDescent, ...
%         registration.metric.MeanSquares);