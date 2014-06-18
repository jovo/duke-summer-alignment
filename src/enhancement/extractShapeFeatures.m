function [ features, centers ] = extractShapeFeatures( A, resize )
%EXTRACTSHAPEFEATURES Summary of this function goes here
%   Detailed explanation goes here

% % find circles with hough transform
% [darkcenters1, darkradii1, darkmetric1] = imfindcircles(A,[15,30], 'EdgeThreshold', 0.25, ...
%     'Sensitivity', 0.95, 'ObjectPolarity', 'dark');
% [darkcenters2, darkradii2, darkmetric2] = imfindcircles(A,[30,60], 'EdgeThreshold', 0.25, ...
%     'Sensitivity', 0.95, 'ObjectPolarity', 'dark');
% [lightcenters1, lightradii1, lightmetric1] = imfindcircles(A,[15,30], 'EdgeThreshold', 0.25, ...
%     'Sensitivity', 0.95, 'ObjectPolarity', 'bright');
% [lightcenters2, lightradii2, lightmetric2] = imfindcircles(A,[30,60], 'EdgeThreshold', 0.25, ...
%     'Sensitivity', 0.95, 'ObjectPolarity', 'bright');
% 
% centers = [darkcenters1; darkcenters2; lightcenters1; lightcenters2];
% radii = [darkradii1; darkradii2; lightradii1; lightradii2];
% metric = [darkmetric1; darkmetric2; lightmetric1; lightmetric2];
% 
% [metric,I]=sort(metric, 'descend');
% centers=centers(I,:);
% radii=radii(I,:);
% 
% howmany = min(k, length(radii));
% centersStrong = centers(1:howmany,:);
% radiiStrong = radii(1:howmany);
% metricStrong = metric(1:howmany);
% figure; imshow(A);
% viscircles(centersStrong, radiiStrong, 'EdgeColor', 'b');

% 
Atemp = imresize(imsharpen(medfilt2(A, [3,3]), 'Radius', 5, 'Amount', 2), resize);
Ascaled = imresize(A, resize);

% convert to binary
Atemp = im2bw(Atemp);
Acomp = imcomplement(Atemp);

% loop parameters
seD = strel('disk',3);
split = 15;
yincrement = floor(size(Atemp,1)/split);
xincrement = floor(size(Atemp,2)/split);
fsize = split^2*yincrement*xincrement;

% data structures
features = NaN(fsize, 3);
centers = NaN(fsize, 2);
shift = NaN(fsize, 2);
imgsize = NaN(fsize, 2);
imgs = cell(fsize,1);
explored = NaN(fsize,1);

c = 1;
% loop over positions
for y=yincrement:yincrement:yincrement*split-1
    for x=xincrement:xincrement:xincrement*split-1
        
        % compute binary image shape
        Afilled = imcomplement(imfill(Acomp, [y,x]));
        Anoborder = imclearborder(imdilate(imfill(Atemp-Afilled, 'holes'),seD), 4);
        
        if std(double(Anoborder(:))) ~= 0
            
            [Afinal,yshiftmin,xshiftmin,~,~] = rmzeropadding(Anoborder);

            % get region properties
            stats = regionprops(Afinal, 'Centroid', 'FilledArea', ...
                'Eccentricity', 'EulerNumber', 'ConvexArea', 'Solidity');
            
            if sum(ismember(explored, stats.FilledArea)) == 0 && ...
                    stats.Eccentricity < 0.9 && stats.EulerNumber > 0 && ...
                    stats.FilledArea > 100

                explored(c) = stats.FilledArea;

                % save centroid of each region
                shift(c,:) = [yshiftmin, xshiftmin];
                centers(c,:) = [shift(c,1) + stats.Centroid(2), shift(c,2) + stats.Centroid(1)];
                
                imgsize(c,:) = size(Afinal);
                imgs{c} = Afinal;
                
                % get actual image properties
                yrange = (1:imgsize(c,1))+shift(c,1);
                xrange = (1:imgsize(c,2))+shift(c,2);
                Avalid = Ascaled(yrange, xrange);
                validvalues = double(Avalid(Afinal==1));
                
                % save features
                features(c,1) = stats.FilledArea;
                features(c,2) = stats.Eccentricity;
                features(c,3) = stats.Solidity;
                features(c,4) = mean(validvalues);
                features(c,5) = var(validvalues);
                c = c + 1;
            end
        end
    end
end
nanele = isnan(centers(:,1));
features(nanele,:) = [];
centers(nanele,:) = [];
shift(nanele,:) = [];
imgsize(nanele,:) = [];
imgs(nanele,:) = [];

Ashow = Ascaled;
for i=1:size(shift,1)
    yindex = shift(i,1)+1:shift(i,1)+imgsize(i,1);
    xindex = shift(i,2)+1:shift(i,2)+imgsize(i,2);
    Ashow(yindex,xindex) = uint8((imgs{i}*255+double(Ashow(yindex,xindex)))./2);
end
figure; imshow(Ashow)
hold on
for i=1:size(shift,1)
    plot(centers(i,2), centers(i,1), 'ro');
end

end
