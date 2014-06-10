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
IStackNew = NaN(ysize, xsize, zsize + zsize*count);
IStackSize = NaN(zsize + zsize*count, 2);
IStackNew(:,:,1:zsize) = IStack;
IStackSize(1:zsize,:) = [ones(zsize,1)*ysize, ones(zsize,1)*xsize];

% distribution from which to draw random numbers
betaD = makedist('Beta', 1, 3);
counter = size(IStack,3)+1;

% extend the original image stack to include more training sets
for i=1:size(IStack,3)  % iterate through each slice
    cursize = floor(mindim + random(betaD, [count,1]) * (maxdim-mindim));   % size of image in this iteration
    randSY = ceil(rand([count,1]) .* (ysize-cursize));
    randSX = ceil(rand([count,1]) .* (xsize-cursize));
    for j=1:count   % iterate through each random sample
        curimage = IStack(1+randSY(j):cursize(j)+randSY(j),1+randSX(j):cursize(j)+randSX(j),i);
        IStackNew(1:cursize(j), 1:cursize(j), counter) = curimage;
        IStackSize(counter, :) = [cursize(j), cursize(j)];
        counter = counter+1;
    end
end

% update size of training image stack
ysize = size(IStackNew, 1);
xsize = size(IStackNew, 2);
zsize = size(IStackNew, 3);

% preallocate matrices
maxfeaturecount = 100;  % maximum possible # of features.
XT = NaN(zsize, maxfeaturecount);
XF = NaN(zsize, maxfeaturecount);

% compute transformation parameters
randY = floor(rand(zsize-1,1) * min(ysize,xsize)/10);
randX = floor(rand(zsize-1,1) * min(ysize,xsize)/10);
randT = rand(zsize-1,1) * 360;
randS = rand(zsize-1,1) * 1.1;
Tparam = [randY, randX, randT, randS];

% iterate through expanded stack, compute features.
counterT = 1;
counterF = 1;
for i=1:size(IStackNew,3)-1
    
    % compute cross correlation of correct alignment
    img1 = IStackNew(1:IStackSize(i,1),1:IStackSize(i,2),i);
    img2 = IStackNew(1:IStackSize(i+1,1),1:IStackSize(i+1,2),i+1);
    cT = normxcorr2(img2, img1);

    % find peak of aligned image
    [ymaxT, xmaxT] = find(cT==max(cT(:)));
    featuresT = getpeakfeatures(cT, ymaxT, xmaxT);
    XT(counterT, 1:size(featuresT,2)) = featuresT;
    counterT = counterT + 1;

    % apply transform to one image, compute xcorr of incorrect alignment
    merged = affinetransform(img2, img1, params2matrix(Tparam(i,:)));
    cF = normxcorr2(merged(:,:,1), merged(:,:,2));

    % find incorrect peak of unaligned image
    [ymaxF, xmaxF] = find(cF==max(cF(:)));
    featuresF = getpeakfeatures(cF, ymaxF, xmaxF);
    XF(counterF, 1:size(featuresF,2)) = featuresF;
    counterF = counterF + 1;

end

% remove unfilled feature matrix entries
nonzerocols = ~all(isnan(XT),1);
nonzerorows = ~all(isnan(XT),2);
XT = XT(nonzerorows, :);
XT = XT(:, nonzerocols);
XF = XF(nonzerorows, :);
XF = XF(:, nonzerocols);

% assign ground truth
YT = ones(size(XT,1),1);
YF = zeros(size(XF,1),1);

% randomly sort true and false values
X = [XT; XF];
Y = [YT; YF];

end
