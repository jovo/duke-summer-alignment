function [ X, Y, XTrue, XFalse ] = generategroundtruth( IStack )
%GENERATEGROUNDTRUTH Generate a bunch of training inputs for classfiers
%   [ X, Y ] = generategroundtruth( IStack )

% preallocate matrices
maxfeaturecount = 100;  % maximum possible # of features.
XTrue = NaN(size(IStack,3), maxfeaturecount);
XFalse = NaN(size(IStack,3)*3, maxfeaturecount);

% iterate through stack, compute features.
counter = 1;
for i=1:size(IStack,3)-1
    % compute cross correlation
    c = normxcorr2(IStack(:,:,i), IStack(:,:,i+1));
    imshow(c, [min(c(:)), max(c(:))]);
    impixelregion;
    getpts;
    % select peak pixels
    title('select peak pixels');
    answer = inputdlg({'Enter x coordinate:', 'Enter y coordinate:'});
    xp = str2double(answer{1});
    yp = str2double(answer{2});
    features = getpeakfeatures(c, yp, xp);
    XTrue(i,1:size(features,2)) = features;
    
    % select non-peak pixels
    for k=1:3
        yrand = ceil(rand*(size(c,1)-1));
        xrand = ceil(rand*(size(c,2)-1));
        if xrand ~= xp && yrand ~= yp
            features = getpeakfeatures(c, yrand, xrand);
            XFalse(counter,1:size(features,2)) = features;
            counter = counter + 1;
        end
    end
end

% remove unfilled feature matrix entries
XTrue(isnan(XTrue)) = [];
XFalse(isnan(XFalse)) = [];

% assign ground truth
YTrue = ones(size(XTrue,1));
YFalse = zeros(size(XFalse,1));

% randomly sort true and false values
Xtemp = [XTrue; XFalse];
Ytemp = [YTrue; YFalse];
randp = randperm(length(Xtemp));
Y = Ytemp(randp);
X = Xtemp(randp);

end
