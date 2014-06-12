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

% save variable in .mat to free up memory
filename = strcat('generategroundtruth_tempfile_', lower(randseq(8, 'Alphabet', 'amino')), '.mat');
data = matfile(filename, 'Writable', true);
% stores all training sets
data.IStackNew = zeros(ysize, xsize, zsize, count+1, 'uint8');
data.IStackNew(:,:,1:zsize,1) = IStack;
data.IStackSize = NaN(count+1,2);
data.IStackSize(1,:) = [ysize,xsize];

for i=1:count    % iterate through each random sample
    cursize = floor(mindim + random('beta',1,3) * (maxdim-mindim));   % size of image in this iteration
    randSY = ceil(rand .* (ysize-cursize));
    randSX = ceil(rand .* (xsize-cursize));
    curStack = zeros(cursize, cursize, zsize, 'uint8');
    for j=1:zsize
        curStack(:,:,j) = IStack(1+randSY:cursize+randSY,1+randSX:cursize+randSX,j);
    end
    data.IStackNew(1:cursize,1:cursize,1:zsize,i+1) = curStack;
    clear curStack;
    data.IStackSize(i+1,:) = [cursize, cursize];
end
clear IStack;

% preallocate matrices
maxfeaturecount = 10;  % maximum possible # of features.
XT = NaN((zsize-1)*(count+1), maxfeaturecount);
XF = NaN((zsize-1)*(count+1), maxfeaturecount);

% iterate through expanded stack, compute features.
counterT = 1;
counterF = 1;
for i=1:count+1

    % retrieve size of image for this iteration
    ysize = data.IStackSize(i,1);
    xsize = data.IStackSize(i,2);

    % compute transformation parameters
    randY = floor(random('beta',1,3,[zsize-1,1]) * min(ysize,xsize)/20);
    randX = floor(random('beta',1,3,[zsize-1,1]) * min(ysize,xsize)/20);
    randT = 5 + random('beta',1,3,[zsize-1,1]) * 350;
    randS = random('beta',1,3,[zsize-1,1]) * 1.1;
    Tparam = [randY, randX, randT, randS];

    for j=1:zsize-1   % iterate through each image in stack
        % access image pair and remove NaN
        img1 = data.IStackNew(1:ysize,1:xsize,j,i);
        img2 = data.IStackNew(1:ysize,1:xsize,j+1,i);
        % compute cross correlation of correct alignment
        cT = normxcorr2(img2, img1);
        % find peak of aligned image
        [ymaxT, xmaxT] = find(cT==max(cT(:)));
        featuresT = getpeakfeatures(cT, ymaxT, xmaxT);
        clear cT;
        XT(counterT, 1:size(featuresT,2)) = featuresT;
        counterT = counterT + 1;

        % apply transform to one image, compute xcorr of incorrect alignment
        merged = affinetransform(img2, img1, params2matrix(Tparam(j,:)));
        clear img1 img2;
        cF = normxcorr2(merged(:,:,1), merged(:,:,2));
        clear merged;

        % find incorrect peak of unaligned image
        [ymaxF, xmaxF] = find(cF==max(cF(:)));
        featuresF = getpeakfeatures(cF, ymaxF, xmaxF);
        clear cF;
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
YT = true(size(XT,1),1);
YF = false(size(XF,1),1);

% concatenate true and false entries
X = [XT; XF];
Y = [YT; YF];

end
