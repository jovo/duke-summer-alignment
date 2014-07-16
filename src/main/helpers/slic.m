function [ L ] = slic( Image, k )
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
for i=1:size(cCenter, 1)
    xindex = cCenter(i, 2);
    yindex = cCenter(i, 3);
    xrange = max(1, xindex-1) : min(size(Image,2), xindex+1);
    yrange = max(1, yindex-1) : min(size(Image,1), yindex+1);
    cropped = Image(yrange, xrange);
    grad = gradient(cropped);
    [ymin, xmin] = find(grad==min(grad(:)), 1);
    newx = min(xrange) - 1 + xmin;
    newy = min(yrange) - 1 + ymin;
    cCenter(i, :) = [Image(newy, newx), newx, newy];
end

% iterately find better cluster centers
E = Inf;
while(E > errorthreshold)

    % distance and label assignment
    for i=1:size(cCenter, 1)
        Ck = cCenter(i, :);
        xindex = cCenter(i, 2);
        yindex = cCenter(i, 3);
        xrange = max(1, xindex-S*2) : min(size(Image,2), xindex+S*2);
        yrange = max(1, yindex-S*2) : min(size(Image,1), yindex+S*2);
        [xtemp, ytemp] = meshgrid(xrange, yrange);
        linrange = sub2ind(size(Image), ytemp(:), xtemp(:));
        Ci = C(linrange, :);
        curdist = distanceVector(linrange);
        curlabel = labelVector(linrange);
        D = pairdist(Ck, Ci, S, m);
        update = D < curdist;
        distanceVector(linrange) = min(D, curdist);
        curlabel(update) = i;
        labelVector(linrange) = curlabel;
    end

    % calculate new cluster centers
    ccNew = cCenter;
    for i=1:size(ccNew, 1)
        curpixels = C(labelVector==i,:);
        ccNew(i, :) = mean(curpixels, 1);
        ccNew(i, 2:3) = round(ccNew(i, 2:3));
    end
    % compute residual error (L2)
    E = sum(sqrt((ccNew(:,1)-cCenter(:,1)).^2 + (ccNew(:,2)-cCenter(:,2)).^2 + (ccNew(:,3)-cCenter(:,3)).^2));
    % update old cluster centers
    cCenter = ccNew;

end

% enforce connectivity (fill in holes)
labelMatrix = zeros(size(Image));
labelMatrix(sub2ind(size(labelMatrix), C(:,3), C(:,2))) = labelVector;
clear distanceVector labelVector C;
for i=1:3
    finalMatrix = zeros(size(Image));
    for l=1:size(cCenter, 1)
        bwfill = bwmorph(labelMatrix==l, 'fill');
        cc = bwconncomp(bwfill, 4);
        if l==27
            figure; imshow(bwfill);
        end
        if cc.NumObjects > 1
            rp = regionprops(cc, 'Area', 'PixelIdxList');
            [~, ind] = sort([rp.Area], 'descend');
            for j=2:cc.NumObjects
                bwfill(cc.PixelIdxList{ind(j)}) = 0;
            end
            if i==3
                figure; imshow(bwfill);
            end
        end
        finalMatrix(bwfill) = l;
    end
    labelMatrix = finalMatrix;
end

% fill in orphaned pixels with value of nearest cluster center.
cc = bwconncomp(finalMatrix==0, 4);
rp = regionprops(cc, 'Extrema');
for i=1:size(rp, 1)
    extrema = rp(i).Extrema;
    ymin = floor(min(extrema(:,2)));
    ymax = ceil(max(extrema(:,2)));
    xmin = floor(min(extrema(:,1)));
    xmax = ceil(max(extrema(:,1)));
    xrange = max(1, xmin-1) : min(size(finalMatrix, 2), xmax+1);
    yrange = max(1, ymin-1) : min(size(finalMatrix, 1), ymax+1);
    I = finalMatrix(yrange, xrange);
    I(I==0) = [];
    finalMatrix(cc.PixelIdxList{i}) = mode(I);
end
L = finalMatrix;

for i=1:k
    Prp = regionprops(finalMatrix==i, 'Centroid', 'Area');
    if length([Prp.Area]) > 1
        figure; imshow(finalMatrix==i);
    end
end
    
    % normalized distance function
    function D2 = pairdist(ck, ci, s, m)
        dc = sqrt( (ci(:,1)-ck(:,1)).^2 );
        ds = sqrt( (ci(:,2)-ck(:,2)).^2 + (ci(:,3)-ck(:,3)).^2 );
        D2 = sqrt( dc.^2 + m^2*(ds/s).^2 );
    end

end
