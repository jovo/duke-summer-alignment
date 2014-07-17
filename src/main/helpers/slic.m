function [ L, Final ] = slic( Image, k )
%SLIC Implementation of SLIC for grayscale images.
%   function [ L ] = slic( Image, k ) Image is the grayscale
%   image to segment into k superpixels. L is the label matrix identifying
%   the superpixel regions.
% 
%   Adapted from SLIC Superpixels Compared to State-of-the-art Superpixel Methods
%   Achanta et al., 2011

% convert to LAB color space
Image = uint8(Image);
colortemp = lab2double(applycform(cat(3, Image, Image, Image), makecform('srgb2lab')));
Image = colortemp(:,:,1);
clear colortemp;

% initialize variables
m = 30;
errorthreshold = 10;
pixelcount = size(Image, 1)*size(Image, 2);
S = floor(sqrt(pixelcount / k));
[Y, X] = ind2sub(size(Image), 1:pixelcount);
C = [double(Image(:)), X', Y'];
clear X Y;

% set label and distance
labelVector = ones(pixelcount, 1) * (-1);
distanceVector = Inf(pixelcount, 1);

% initialize cluster centers
ycount = floor(size(Image, 1) / S);
xcount = floor(size(Image, 2) / S);
yCluster = (1:ycount) * S;
xCluster = (1:xcount) * S;
imgtemp = Image(yCluster, xCluster);
[xtemp, ytemp] = meshgrid(xCluster, yCluster);
cCenter = [imgtemp(:), xtemp(:), ytemp(:)];
clear imgtemp xCluster yCluster ycount xcount xtemp ytemp;

% move cluster centers to lowest gradient position in 3x3 neighborhood
for k=1:size(cCenter, 1)
    xindex = cCenter(k, 2);
    yindex = cCenter(k, 3);
    xrange = max(1, xindex-1) : min(size(Image,2), xindex+1);
    yrange = max(1, yindex-1) : min(size(Image,1), yindex+1);
    cropped = Image(yrange, xrange);
    grad = gradient(cropped);
    [ymin, xmin] = find(grad==min(grad(:)), 1);
    newx = min(xrange) - 1 + xmin;
    newy = min(yrange) - 1 + ymin;
    cCenter(k, :) = [Image(newy, newx), newx, newy];
end

% iterately find better cluster centers
E = Inf;
while(E > errorthreshold)

    % distance and label assignment
    for k=1:size(cCenter, 1)
        Ck = cCenter(k, :);
        xindex = cCenter(k, 2);
        yindex = cCenter(k, 3);
        xrange = max(1, xindex-S*2) : min(size(Image,2), xindex+S*2);
        yrange = max(1, yindex-S*2) : min(size(Image,1), yindex+S*2);
        [xtemp, ytemp] = meshgrid(xrange, yrange);
        linrange = sub2ind(size(Image), ytemp(:), xtemp(:));
        Ci = C(linrange, :);
        curdist = distanceVector(linrange);
        curlabel = labelVector(linrange);
        
        cropped = Image(yrange, xrange);
        start_point = [yindex-min(yrange);xindex-min(xrange)];
        D = pairdist2(cropped, start_point);
        
%         D = pairdist(Ck, Ci, S, m);
        update = D(:) < curdist;
        distanceVector(linrange) = min(D(:), curdist);
        curlabel(update) = k;
        labelVector(linrange) = curlabel;
    end

    % calculate new cluster centers
    ccNew = cCenter;
    for k=1:size(ccNew, 1)
        curpixels = C(labelVector==k,:);
        ccNew(k, :) = mean(curpixels, 1);
        ccNew(k, 2:3) = round(ccNew(k, 2:3));
    end
    % compute residual error (L2)
    E = sum(sqrt((ccNew(:,1)-cCenter(:,1)).^2 + (ccNew(:,2)-cCenter(:,2)).^2 + (ccNew(:,3)-cCenter(:,3)).^2));
    % update old cluster centers
    cCenter = ccNew;

end

% % enforce connectivity (fill in holes)
% for i=1:size(cCenter, 1)
%     xindex = cCenter(i, 2);
%     yindex = cCenter(i, 3);
%     xrange = max(1, xindex-S*2) : min(size(Image,2), xindex+S*2);
%     yrange = max(1, yindex-S*2) : min(size(Image,1), yindex+S*2);
%     cropped = Image(yrange, xrange);
%     
%     start_point = [yindex-min(yrange);xindex-min(xrange)];
%     options.nb_iter_max = Inf;
%     D = perform_fast_marching(cropped, start_point, options);
%     
% %     start_point = [yindex-min(yrange);xindex-min(xrange)];
% %     D = msfm2d(cropped, start_point, true, true);
%     
%     [xtemp, ytemp] = meshgrid(xrange, yrange);
%     linrange = sub2ind(size(Image), ytemp(:), xtemp(:));
%     curdist = distanceVector(linrange);
%     curlabel = labelVector(linrange);
%     update = D(:) < curdist;
%     distanceVector(linrange) = min(D(:), curdist);
%     curlabel(update) = i;
%     labelVector(linrange) = curlabel;
%     
% end
L = zeros(size(Image));
L(sub2ind(size(L), C(:,3), C(:,2))) = labelVector;
Final = Image;
E = edge(L, 'sobel', 0);
Final(E) = 0;

    % normalized distance function
    function D2 = pairdist(ck, ci, s, m)
        dc = sqrt( (ci(:,1)-ck(:,1)).^2 );
        ds = sqrt( (ci(:,2)-ck(:,2)).^2 + (ci(:,3)-ck(:,3)).^2 );
        D2 = sqrt( dc.^2 + m^2*(ds/s).^2 );
    end

    function D2 = pairdist2(cropped, start_point)
        opt.nb_iter_max = Inf;
        D2 = perform_fast_marching(cropped, start_point, opt);
    end

end
