function [ X, Y, XT, XF ] = generategroundtruth( IStack, count, mindim, maxdim )
%GENERATEGROUNDTRUTH Generate a bunch of training inputs for classifiers
%   [ X, Y, XT, XF ] = generategroundtruth( IStack, count, size )
%   IStack is the stack of images to use to generate ground truth. count
%   indicates how many samples of dimension randomly between mindim and
%   maxdim to to take for each image.

% access size of inputs for training image stack
ysize = size(IStack, 1);
xsize = size(IStack, 2);
zsize = size(IStack, 3);

% size of new training set
IStackNew = cell(count,1);
IStackNew{1} = IStack;

% distribution from which to draw random numbers
betaD = makedist('Beta', 1, 3);

for i=1:count    % iterate through each random sample
    cursize = floor(mindim + random(betaD) * (maxdim-mindim));   % size of image in this iteration
    randSY = ceil(rand .* (ysize-cursize));
    randSX = ceil(rand .* (xsize-cursize));
    curStack = NaN(cursize, cursize, zsize);
    for j=1:zsize
        curStack(:,:,j) = IStack(1+randSY:cursize+randSY,1+randSX:cursize+randSX,j);
    end
    IStackNew{i+1} = curStack;
end

% preallocate matrices
maxfeaturecount = 100;  % maximum possible # of features.
XT = NaN((zsize-1)*(count+1), maxfeaturecount);
XF = NaN((zsize-1)*(count+1), maxfeaturecount);

% iterate through expanded stack, compute features.
counterT = 1;
counterF = 1;
for i=1:length(IStackNew)

    % current stack
    curStack = IStackNew{i};

    % compute transformation parameters
    randY = min(ysize,xsize)/20 + floor(rand(zsize-1,1) * min(ysize,xsize)/20);
    randX = min(ysize,xsize)/20 + floor(rand(zsize-1,1) * min(ysize,xsize)/20);
    randT = 30 + rand(zsize-1,1) * 300;
    randS = rand(zsize-1,1) * 1.1;
    Tparam = [randY, randX, randT, randS];

    for j=1:zsize-1   % iterate through each image in stack
        % compute cross correlation of correct alignment
        img1 = curStack(:,:,j);
        img2 = curStack(:,:,j+1);
        cT = normxcorr2(img2, img1);

        % find peak of aligned image
        [ymaxT, xmaxT] = find(cT==max(cT(:)));
        featuresT = getpeakfeatures(cT, ymaxT, xmaxT);
        XT(counterT, 1:size(featuresT,2)) = featuresT;
        counterT = counterT + 1;

        % apply transform to one image, compute xcorr of incorrect alignment
        merged = affinetransform(img2, img1, params2matrix(Tparam(j,:)));
        cF = normxcorr2(merged(:,:,1), merged(:,:,2));

        % find incorrect peak of unaligned image
        [ymaxF, xmaxF] = find(cF==max(cF(:)));
        featuresF = getpeakfeatures(cF, ymaxF, xmaxF);
        XF(counterF, 1:size(featuresF,2)) = featuresF;
        counterF = counterF + 1;
    end
end

% remove naN feature matrix rows and cols
nonzerocols = ~all(isnan(XT),1);
nonzerorows = ~all(isnan(XT),2);
XT = XT(nonzerorows, :);
XT = XT(:, nonzerocols);
XF = XF(nonzerorows, :);
XF = XF(:, nonzerocols);

% assign ground truth
YT = ones(size(XT,1),1);
YF = zeros(size(XF,1),1);

% concatenate true and false entries
X = [XT; XF];
Y = [YT; YF];

end
